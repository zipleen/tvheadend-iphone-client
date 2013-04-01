//
//  TVHSettings.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright 2013 Luis Fernandes
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

#import "TVHSettings.h"
#import "TVHJsonClient.h"
#import "PDKeychainBindings.h"
#import <CommonCrypto/CommonDigest.h>
#define TVHS_CACHING_TIME @"CachingTime"
#define TVHS_AUTO_START_COMET_POOL @"AutoStartCometPool"
#define TVHS_CUSTOM_PREFIX @"CustomAppPrefix"
#define TVHS_SEND_ANONSTATS @"sendAnonymousStatistics"

@interface TVHSettings()

@end

@implementation TVHSettings
@synthesize baseURL = _baseURL;
@synthesize username = _username;
@synthesize password = _password;
@synthesize selectedServer = _selectedServer;
@synthesize cacheTime = _cacheTime;
@synthesize autoStartPolling = _autoStartPolling;
@synthesize sortChannel = _sortChannel;
@synthesize sendAnonymousStatistics = _sendAnonymousStatistics;

+ (id)sharedInstance {
    static TVHSettings *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHSettings alloc] init];
    });
    
    return __sharedInstance;
}

#pragma mark crypto

- (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

- (void)setProtectedString:(NSString*)string forKey:(NSString*)key {
    PDKeychainBindings *protectedSettings = [PDKeychainBindings sharedKeychainBindings];
    [protectedSettings setString:string forKey:key];
}

- (NSString*)protectedString:(NSString*)key {
    PDKeychainBindings *protectedSettings = [PDKeychainBindings sharedKeychainBindings];
    return [protectedSettings stringForKey:key];
}

#pragma mark Servers

- (NSString*)md5ForServer:(NSString*)server withPort:(NSString*)port withUser:(NSString*)username {
    return [NSString stringWithFormat:@"%@|%@|%@", server, port, username];
}

- (void)setPasswordForServer:(NSString*)server withPort:(NSString*)port withUser:(NSString*)username
withPassword:(NSString*)password {
    [self setProtectedString:password forKey:[self md5ForServer:server withPort:port withUser:username]];
}

- (NSString*)passwordForServer:(NSString*)server withPort:(NSString*)port withUser:(NSString*)username {
    return [self protectedString:[self md5ForServer:server
                                           withPort:port
                                           withUser:username]
            ];
}

- (NSArray*)availableServers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *servers = [defaults objectForKey:TVHS_SERVERS];
    if (servers == nil) {
        servers = [[NSArray alloc] init];
    }
    return servers;
}

- (NSString*)serverProperty:(NSString*)key forServer:(NSInteger)serverId {
    NSArray *servers = self.availableServers;
    if ( serverId < [servers count] ) {
        NSDictionary *myServer = [servers objectAtIndex:serverId];
        if ( [key isEqualToString:TVHS_PASSWORD_KEY] ) {
            return [self passwordForServer:[myServer objectForKey:TVHS_IP_KEY]
                                  withPort:[myServer objectForKey:TVHS_PORT_KEY]
                                  withUser:[myServer objectForKey:TVHS_USERNAME_KEY]];
        } else if ( [key isEqualToString:TVHS_SSH_PF_PASSWORD] ) {
            return [self passwordForServer:[myServer objectForKey:TVHS_SSH_PF_HOST]
                                  withPort:[myServer objectForKey:TVHS_SSH_PF_PORT]
                                  withUser:[myServer objectForKey:TVHS_SSH_PF_USERNAME]];
        } else {
            return [myServer objectForKey:key];
        }
    }
    return nil;
}

- (void)setServerProperties:(NSDictionary*)properties forServerId:(NSInteger)serverId {
    NSMutableArray *servers = [self.availableServers mutableCopy];
    NSString *password = [properties objectForKey:TVHS_PASSWORD_KEY];
    NSString *sshPassword = [properties objectForKey:TVHS_SSH_PF_PASSWORD];
    
    // remove password from saved array
    NSMutableDictionary *server = [properties mutableCopy];
    [server removeObjectForKey:TVHS_PASSWORD_KEY];
    [server removeObjectForKey:TVHS_SSH_PF_PASSWORD];
    
    // save password in keychain
    [self setPasswordForServer:[server objectForKey:TVHS_IP_KEY]
                      withPort:[server objectForKey:TVHS_PORT_KEY]
                      withUser:[server objectForKey:TVHS_USERNAME_KEY]
                  withPassword:password];
    
    [self setPasswordForServer:[server objectForKey:TVHS_SSH_PF_HOST]
                      withPort:[server objectForKey:TVHS_SSH_PF_PORT]
                      withUser:[server objectForKey:TVHS_SSH_PF_USERNAME]
                  withPassword:sshPassword];
    
    if ( serverId == -1 ) {
        [servers addObject:server];
    } else {
        [servers replaceObjectAtIndex:serverId withObject:server];
    }
    
    // save all servers
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:servers forKey:TVHS_SERVERS];
    [defaults synchronize];
}

- (NSDictionary*)serverProperties:(NSInteger)serverId {
    NSArray *servers = self.availableServers;
    if ( serverId < [servers count] ) {
        NSMutableDictionary *server = [[servers objectAtIndex:serverId] mutableCopy];
        [server setValue:[self serverProperty:TVHS_PASSWORD_KEY forServer:serverId] forKey:TVHS_PASSWORD_KEY];
        [server setValue:[self serverProperty:TVHS_SSH_PF_PASSWORD forServer:serverId] forKey:TVHS_SSH_PF_PASSWORD];
        return [server copy];
    }
    return nil;
}

- (NSString*)currentServerProperty:(NSString*)key {
    return [self serverProperty:key forServer:self.selectedServer];
}

- (NSDictionary*)newServer {
    NSDictionary *newServer = @{TVHS_SERVER_NAME:@"",
                                TVHS_IP_KEY:@"",
                                TVHS_PORT_KEY:@"9981",
                                TVHS_USERNAME_KEY:@"",
                                TVHS_PASSWORD_KEY:@"",
                                TVHS_SSH_PF_HOST:@"",
                                TVHS_SSH_PF_PORT:@"",
                                TVHS_SSH_PF_USERNAME:@"",
                                TVHS_SSH_PF_PASSWORD:@""};
    
    return newServer;
}

- (NSInteger)selectedServer {
    if ( !_selectedServer ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger selectedServer = [defaults integerForKey:TVHS_SELECTED_SERVER];
        if ( selectedServer < 0 || selectedServer >= [self.availableServers count]  ) {
            return NSNotFound;
        }
        _selectedServer = selectedServer;
    }
    return _selectedServer;
}

- (void)setSelectedServer:(NSInteger)serverId {
    if ( serverId >= 0 && serverId < [self.availableServers count] ) {
        _selectedServer = serverId;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:serverId forKey:TVHS_SELECTED_SERVER];
        [defaults synchronize];
        
        [self resetSettings];
    }
}

- (void)removeServer:(NSInteger)serverId {
    NSMutableArray *servers = [self.availableServers mutableCopy];
    if ( serverId > [servers count] ) {
        return ;
    }
    
    // remove protected password
    NSDictionary *serverToRemove = [servers objectAtIndex:serverId];
    [self setProtectedString:nil
                      forKey:[self md5ForServer:[serverToRemove objectForKey:TVHS_IP_KEY]
                                       withPort:[serverToRemove objectForKey:TVHS_PORT_KEY]
                                       withUser:[serverToRemove objectForKey:TVHS_USERNAME_KEY]]];
    
    [servers removeObjectAtIndex:serverId];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[servers copy] forKey:TVHS_SERVERS];
    [defaults synchronize];
    
    // reset server connection
    if ( [self.availableServers count] > 0 ) {
        NSDictionary *selectedServer = [self.availableServers objectAtIndex:self.selectedServer];
        NSInteger newSelectedServer = [servers indexOfObject:selectedServer];
        if ( newSelectedServer == NSNotFound ) {
            [self setSelectedServer:0];
        } else if ( newSelectedServer != self.selectedServer ) {
            [self setSelectedServer:newSelectedServer];
        }
    }
}

#pragma mark Properties

- (NSURL*)baseURL {
    NSString *ip;
    NSString *port;
    if( !_baseURL ) {
        if ( self.selectedServer == NSNotFound ) {
            return nil;
        }
        
        if ( ![[self currentServerProperty:TVHS_SSH_PF_HOST] isEqualToString:@""] ) {
            ip = @"127.0.0.1";
            port = [NSString stringWithFormat:@"%@", TVHS_SSH_PF_LOCAL_PORT];
        } else {
            ip = [self currentServerProperty:TVHS_IP_KEY];
            port = [self currentServerProperty:TVHS_PORT_KEY];
            if( [port isEqualToString:@""] ) {
                port = @"9981";
            }
        }
        
        NSString *baseUrlString = [NSString stringWithFormat:@"http://%@:%@", ip, port];
        NSURL *url = [NSURL URLWithString:baseUrlString];
        _baseURL = url;
    }
    return _baseURL;
}
- (NSString*)username {
    if ( !_username ) {
        _username = [self currentServerProperty:TVHS_USERNAME_KEY];
    }
    return _username;
}

- (NSString*)password {
    if ( !_password ) {
        _password = [self currentServerProperty:TVHS_PASSWORD_KEY];
    }
    return _password;
}

- (void)resetSettings {
    _baseURL = nil;
    _username = nil;
    _password = nil;
    
    [[[TVHJsonClient sharedInstance] operationQueue] cancelAllOperations];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"resetAllObjects"
     object:nil];
}

- (NSTimeInterval)cacheTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval time = [defaults integerForKey:TVHS_CACHING_TIME];
    if ( time < 0 ) {
        time = 180;
    }
    return time;
}

- (void)setCacheTime:(NSTimeInterval)time {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:time forKey:TVHS_CACHING_TIME];
}

- (BOOL)autoStartPolling {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id test = [defaults objectForKey:TVHS_AUTO_START_COMET_POOL];
    if ( test == nil ) {
        _autoStartPolling = YES;
        return _autoStartPolling;
    }
    _autoStartPolling = [defaults boolForKey:TVHS_AUTO_START_COMET_POOL];
    return _autoStartPolling;
}

- (void)setAutoStartPolling:(BOOL)autoStart {
    _autoStartPolling = autoStart;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:autoStart forKey:TVHS_AUTO_START_COMET_POOL];
    [defaults synchronize];
}

- (NSString*)customPrefix {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:TVHS_CUSTOM_PREFIX];
}

- (void)setCustomPrefix:(NSString*)customPrefix {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:customPrefix forKey:TVHS_CUSTOM_PREFIX];
    [defaults synchronize];
}

- (NSInteger)sortChannel {
    if ( !_sortChannel ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id test = [defaults objectForKey:TVHS_SORT_CHANNEL];
        if ( test == nil ) {
            _sortChannel = TVHS_SORT_CHANNEL_BY_NAME;
        } else {
            _sortChannel = [defaults integerForKey:TVHS_SORT_CHANNEL];
        }
    }
    return _sortChannel;
}

- (void)setSortChannel:(NSInteger)sortChannel {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sortChannel forKey:TVHS_SORT_CHANNEL];
    [defaults synchronize];
    _sortChannel = sortChannel;
}

- (BOOL)sendAnonymousStatistics {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id test = [defaults objectForKey:TVHS_SEND_ANONSTATS];
    if ( test == nil ) {
        _sendAnonymousStatistics = YES;
        return _sendAnonymousStatistics;
    }
    _sendAnonymousStatistics = [defaults boolForKey:TVHS_SEND_ANONSTATS];
    return _sendAnonymousStatistics;
}

- (void)setSendAnonymousStatistics:(BOOL)sendAnonymousStatistics {
    _sendAnonymousStatistics = sendAnonymousStatistics;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:sendAnonymousStatistics forKey:TVHS_SEND_ANONSTATS];
    [defaults synchronize];
}
@end

