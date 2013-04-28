//
//  SSHWrapper.m
//  libssh2-for-iOS
//
//  Created by Felix Schulze on 01.02.11.
//  Copyright 2010 Felix Schulze. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  @see: http://www.libssh2.org/examples/ssh2_exec.html

#import "SSHWrapper.h"

#include "libssh2.h"
#include "libssh2_config.h"
#include "libssh2_sftp.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>

static int waitsocket(int socket_fd, LIBSSH2_SESSION *session)
{
    struct timeval timeout;
    int rc;
    fd_set fd;
    fd_set *writefd = NULL;
    fd_set *readfd = NULL;
    int dir;

    timeout.tv_sec = 10;
    timeout.tv_usec = 0;

    FD_ZERO(&fd);

    FD_SET(socket_fd, &fd);

    /* now make sure we wait in the correct direction */
    dir = libssh2_session_block_directions(session);

    if(dir & LIBSSH2_SESSION_BLOCK_INBOUND)
        readfd = &fd;

    if(dir & LIBSSH2_SESSION_BLOCK_OUTBOUND)
        writefd = &fd;

    rc = select(socket_fd + 1, readfd, writefd, NULL, &timeout);

    return rc;
}

@implementation SSHWrapper {
    int sock;
    LIBSSH2_SESSION *session;
    LIBSSH2_CHANNEL *channel;
    int rc;
}

- (void)dealloc {
    [self closeConnection];
    session = nil;
    channel = nil;
}

- (const char*)addressesForHostname:(NSString *)hostname {
	const char* hostnameC = [hostname cStringUsingEncoding:NSUTF8StringEncoding];
    struct hostent *host_entry = gethostbyname(hostnameC);
    const char *buff;
    if ( host_entry != NULL ) {
        buff = inet_ntoa(*((struct in_addr *)host_entry->h_addr_list[0]));
        return buff;
    }
    return NULL;
}

- (BOOL)connectToHost:(NSString *)host port:(int)port user:(NSString *)user password:(NSString *)password error:(NSError *)error {
    if (host.length == 0) {
        error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:300 userInfo:@{NSLocalizedDescriptionKey:@"No host"}];
        return false;
    }
    
    const char* hostChar = [self addressesForHostname:host];
	const char* userChar = [user cStringUsingEncoding:NSUTF8StringEncoding];
	const char* passwordChar = [password cStringUsingEncoding:NSUTF8StringEncoding];
    struct sockaddr_in sock_serv_addr;
    if ( hostChar == NULL ) {
        error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:400 userInfo:@{NSLocalizedDescriptionKey:@"Failed to resolve DNS name"}];
        return false;
    }
    unsigned long hostaddr = inet_addr(hostChar);

    sock = socket(AF_INET, SOCK_STREAM, 0);
    sock_serv_addr.sin_family = AF_INET;
    sock_serv_addr.sin_port = htons(port);
    sock_serv_addr.sin_addr.s_addr = hostaddr;
    if (connect(sock, (struct sockaddr *) (&sock_serv_addr), sizeof(sock_serv_addr)) != 0) {
        error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:400 userInfo:@{NSLocalizedDescriptionKey:@"Failed to connect"}];
        return false;
    }
	
    /* Create a session instance */
    session = libssh2_session_init();
    if (!session) {
        error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:401 userInfo:@{NSLocalizedDescriptionKey : @"Create session failed"}];
        return false;
    }
	
    /* tell libssh2 we want it all done non-blocking */
    libssh2_session_set_blocking(session, 0);
	
    /* ... start it up. This will trade welcome banners, exchange keys,
     * and setup crypto, compression, and MAC layers
     */
    while ((rc = libssh2_session_startup(session, sock)) ==
           LIBSSH2_ERROR_EAGAIN);
    if (rc) {
        error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:402 userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Failure establishing SSH session: %d", rc]}];
        return false;
    }

    if ( strlen(passwordChar) != 0 ) {
		/* We could authenticate via password */
        while ((rc = libssh2_userauth_password(session, userChar, passwordChar)) == LIBSSH2_ERROR_EAGAIN);
		if (rc) {
            error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:403 userInfo:@{NSLocalizedDescriptionKey : @"Authentication by password failed."}];
            return false;
		}
	}
    
    return true;
}

- (NSString *)executeCommand:(NSString *)command error:(NSError *)error {
	const char* commandChar = [command cStringUsingEncoding:NSUTF8StringEncoding];

	NSString *result = nil;
	
    /* Exec non-blocking on the remove host */
    while( (channel = libssh2_channel_open_session(session)) == NULL &&
		  libssh2_session_last_error(session,NULL,NULL,0) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket(sock, session);
    }
    if( channel == NULL )
    {
        error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:501 userInfo:@{NSLocalizedDescriptionKey : @"No channel found."}];
        return nil;
    }
    while( (rc = libssh2_channel_exec(channel, commandChar)) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket(sock, session);
    }
    if( rc != 0 )
    {
        error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:502 userInfo:@{NSLocalizedDescriptionKey : @"Error while exec command."}];
        return nil;
    }
    for( ;; )
    {
        /* loop until we block */
        int rc1;
        do
        {
            char buffer[0x2000];
            rc1 = libssh2_channel_read( channel, buffer, sizeof(buffer) );
            if( rc1 > 0 )
            {
				result = @(buffer);
            }
        }
        while( rc1 > 0 );
		
        /* this is due to blocking that would occur otherwise so we loop on
		 this condition */
        if( rc1 == LIBSSH2_ERROR_EAGAIN )
        {
            waitsocket(sock, session);
        }
        else
            break;
    }
    while( (rc = libssh2_channel_close(channel)) == LIBSSH2_ERROR_EAGAIN )
        waitsocket(sock, session);
	
    libssh2_channel_free(channel);
    channel = NULL;
	
    return result;
	
}


- (void)closeConnection {
    if (session) {
        libssh2_session_disconnect(session, "Normal Shutdown, Thank you for playing");
        libssh2_session_free(session);
        session = nil;
    }
    close(sock);
}


- (void)setPortForwardFromPort:(unsigned int)localPort toHost:(NSString*)remoteHost onPort:(unsigned int)remotePort {
    const char *local_listenip = "0.0.0.0";
    unsigned int local_listenport = localPort;
    const char *remote_desthost = [remoteHost cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned int remote_destport = remotePort;
    
    NSLog(@"%s:%d -> %s:%d", local_listenip, local_listenport, remote_desthost, remote_destport);
    
    int listensock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    struct sockaddr_in sin;
    sin.sin_family = AF_INET;
    sin.sin_port = htons(local_listenport);
    
    if (INADDR_NONE == (sin.sin_addr.s_addr = inet_addr(local_listenip))) {
        perror("inet_addr");
        close(listensock);
    }
    int sockopt = 1;
    setsockopt(listensock, SOL_SOCKET, SO_REUSEADDR, &sockopt, sizeof(sockopt));
    socklen_t sinlen=sizeof(sin);
    if (-1 == bind(listensock, (struct sockaddr *)&sin, sinlen)) {
        perror("bind");
        fprintf(stderr, "after-bind");
        close(listensock);
    }
    if (-1 == listen(listensock, 2)) {
        perror("listen");
        close(listensock);
    }
    
    
    libssh2_session_set_blocking(session, 1);
    
    printf("Waiting for TCP connection on %s:%d...\n",
           inet_ntoa(sin.sin_addr), ntohs(sin.sin_port));
    
    int forwardsock = -1;
    forwardsock = accept(listensock, (struct sockaddr *)&sin, &sinlen);
    if (-1 == forwardsock) {
        perror("accept");
        close(forwardsock);
        close(listensock);
    }
    
    const char *shost;
    unsigned int sport;
    shost = inet_ntoa(sin.sin_addr);
    sport = ntohs(sin.sin_port);
    
    printf("Forwarding connection from %s:%d here to remote %s:%d\n", shost,
           sport, remote_desthost, remote_destport);
    
    channel = libssh2_channel_direct_tcpip_ex(session, remote_desthost,
                                              remote_destport, shost, sport);
    if (!channel) {
        fprintf(stderr, "Could not open the direct-tcpip channel!\n"
                "(Note that this can be a problem at the server!"
                " Please review the server logs.)\n");
        close(forwardsock);
        close(listensock);
        if (channel) libssh2_channel_free(channel);
        return;
    }
    
    /* Must use non-blocking IO hereafter due to the current libssh2 API */
    libssh2_session_set_blocking(session, 0);
    
    int rc2, i;
    fd_set fds;
    struct timeval tv;
    ssize_t len, wr;
    char buf[16384];
    
    while (1) {
        FD_ZERO(&fds);
        FD_SET(forwardsock, &fds);
        tv.tv_sec = 0;
        tv.tv_usec = 100000;
        rc2 = select(forwardsock + 1, &fds, NULL, NULL, &tv);
        if (-1 == rc) {
            perror("select");
            close(forwardsock);
            close(listensock);
            if (channel) libssh2_channel_free(channel);
            return;
        }
        if (rc2 && FD_ISSET(forwardsock, &fds)) {
            len = recv(forwardsock, buf, sizeof(buf), 0);
            if (len < 0) {
                perror("read");
                close(forwardsock);
                close(listensock);
                if (channel) libssh2_channel_free(channel);
                return;
            } else if (0 == len) {
                printf("The client at %s:%d disconnected!\n", shost, sport);
                close(forwardsock);
                close(listensock);
                if (channel) libssh2_channel_free(channel);
                return;
            }
            wr = 0;
            do {
                i = libssh2_channel_write(channel, buf, len);
                if (i < 0) {
                    fprintf(stderr, "libssh2_channel_write: %d\n", i);
                    close(forwardsock);
                    close(listensock);
                    if (channel) libssh2_channel_free(channel);
                    return;
                }
                wr += i;
            } while(i > 0 && wr < len);
        }
        while (1) {
            len = libssh2_channel_read(channel, buf, sizeof(buf));
            if (LIBSSH2_ERROR_EAGAIN == len)
                break;
            else if (len < 0) {
                fprintf(stderr, "libssh2_channel_read: %d", (int)len);
                close(forwardsock);
                close(listensock);
                if (channel) libssh2_channel_free(channel);
                return;
            }
            wr = 0;
            while (wr < len) {
                i = send(forwardsock, buf + wr, len - wr, 0);
                if (i <= 0) {
                    perror("write");
                    close(forwardsock);
                    close(listensock);
                    if (channel) libssh2_channel_free(channel);
                    return;
                }
                wr += i;
            }
            if (libssh2_channel_eof(channel)) {
                printf("The server at %s:%d disconnected!\n",
                       remote_desthost, remote_destport);
                close(forwardsock);
                close(listensock);
                if (channel) libssh2_channel_free(channel);
                return;
            }
        }
        
    }
    
}
@end
