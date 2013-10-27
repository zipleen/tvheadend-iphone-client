//
//  TVHPlayXbmc.m
//  TvhClient
//
//  Created by zipleen on 27/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHPlayXbmc.h"
#include <arpa/inet.h>
#include "AFHTTPClient.h"

#define SERVICE_TYPE @"_xbmc-jsonrpc-h._tcp"
#define DOMAIN_NAME @"local"
#define DISCOVER_TIMEOUT 5.0f

@interface TVHPlayXbmc() <NSNetServiceDelegate,  NSNetServiceBrowserDelegate> {
    NSMutableArray *services;
    NSMutableDictionary *foundServices;
    BOOL searching;
    NSNetServiceBrowser *netServiceBrowser;
    NSTimer *timer;
}
@end

@implementation TVHPlayXbmc

+ (TVHPlayXbmc*)sharedInstance {
    static TVHPlayXbmc *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHPlayXbmc alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    });
    return __sharedInstance;
}

- (void)appWillResignActive:(NSNotification*)note {
    [self stopDiscovery];
}

- (void)appWillEnterForeground:(NSNotification*)note {
    [self startDiscover];
}

- (id)init {
    self = [super init];
    if (self) {
        services = [[NSMutableArray alloc] init];
        foundServices = [[NSMutableDictionary alloc] init];
        netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        
        [self startDiscover];
    }
    return self;
}

- (void)dealloc {
    services = nil;
    foundServices = nil;
    netServiceBrowser = nil;
    [timer invalidate];
    timer = nil;
}

# pragma mark - xbmc results

- (BOOL)playToXbmc:(NSString*)name withURL:(NSString*)url {
    NSString *serverUrl = [foundServices objectForKey:name];
    if ( serverUrl ) {
        NSURL *playXbmc = [NSURL URLWithString:serverUrl];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:playXbmc];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        NSDictionary *httpParams = @{@"jsonrpc": @"2.0",
                                       @"method": @"player.open",
                                       @"params":
                                           @{@"item" :
                                                 @{@"file": url}
                                             }
                                       };
        [httpClient postPath:@"/jsonrpc" parameters:httpParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Did something with %@ and %@ : %@", serverUrl, url, [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            [TVHAnalytics sendEventWithCategory:@"playTo"
                                     withAction:@"Xbmc"
                                      withLabel:@"Success"
                                      withValue:[NSNumber numberWithInt:1]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //NSLog(@"Failed to do something with %@ and %@", serverUrl, url);
            [TVHAnalytics sendEventWithCategory:@"playTo"
                                     withAction:@"Xbmc"
                                      withLabel:@"Fail"
                                      withValue:[NSNumber numberWithInt:1]];
        }];
    }
    return false;
}

- (NSArray*)availableXbmcServers {
    return [foundServices allKeys];
}

- (NSString*)xbmcUrl:(const char*)addressStr onPort:(int)port {
    return [NSString stringWithFormat:@"http://%s:%d", addressStr, port];
}

# pragma mark - resolveIPAddress Methods

- (void)resolveIPAddress:(NSNetService *)service {
    NSNetService *remoteService = service;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:0];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    for (NSData* data in [service addresses]) {
        char addressBuffer[100];
        struct sockaddr_in* socketAddress = (struct sockaddr_in*) [data bytes];
        int sockFamily = socketAddress->sin_family;
        if (sockFamily == AF_INET ) {//|| sockFamily == AF_INET6 should be considered
            const char* addressStr = inet_ntop(sockFamily,
                                               &(socketAddress->sin_addr), addressBuffer,
                                               sizeof(addressBuffer));
            int port = ntohs(socketAddress->sin_port);
            if (addressStr && port) {
                [foundServices setValue:[self xbmcUrl:addressStr onPort:port] forKey:[service name]];
            }
        }
    }
}

- (void)stopDiscovery{
    [timer invalidate];
    [netServiceBrowser stop];
}

- (void)startDiscover{
    [services removeAllObjects];
    
    searching = NO;
    [netServiceBrowser setDelegate:self];
    [netServiceBrowser searchForServicesOfType:SERVICE_TYPE inDomain:DOMAIN_NAME];
    timer = [NSTimer scheduledTimerWithTimeInterval:DISCOVER_TIMEOUT target:self selector:@selector(stopDiscovery) userInfo:nil repeats:NO];
}

# pragma mark - NSNetServiceBrowserDelegate Methods

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser{
    searching = YES;
    [self updateXbmcServers];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser{
    searching = NO;
    [self updateXbmcServers];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict{
    searching = NO;
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing {
    [services addObject:aNetService];
    if ( !moreComing ) {
        //[self stopDiscovery];
        [self updateXbmcServers];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing{
    [services removeObject:aNetService];
    if ( !moreComing ) {
        [self updateXbmcServers];
    }
}

- (void)handleError:(NSNumber *)error {
    NSLog(@"An error occurred. Error code = %d", [error intValue]);
}

- (void)updateXbmcServers {
    if ( !searching ) {
        for (NSNetService *service in services) {
            [self resolveIPAddress:service];
        }
    }
}

@end
