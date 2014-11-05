//
//  TVHSingletonServer.m
//  TvhClient
//
//  Created by Luis Fernandes on 16/05/2013.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHSingletonServer.h"
#import "TVHServerSettings.h"
#import "TVHSettings.h"
#import "TVHModelAnalytics.h"
#import "TVHPlayXbmc.h"

@implementation TVHSingletonServer {
    TVHServer *__tvhserver;
    TVHSettings *settings;
    id<TVHModelAnalyticsProtocol> _analytics;
}

+ (TVHSingletonServer*)sharedInstance {
    static TVHSingletonServer *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHSingletonServer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:__sharedInstance
                                                 selector:@selector(resetServer)
                                                     name:TVHWillDestroyServerNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:__sharedInstance
                                                 selector:@selector(refreshServerVersion)
                                                     name:TVHDidLoadVersionNotification
                                                   object:nil];
    });
    
    return __sharedInstance;
}

#pragma mark Server Init

+ (TVHServer*)sharedServerInstance {
    return [[TVHSingletonServer sharedInstance] serverInstance];
}

- (TVHServer*)serverInstance {
    if ( ! __tvhserver ) {
        __tvhserver = [[TVHServer alloc] initWithSettings:self.serverSettings];
        __tvhserver.analytics = [self analytics];
    }
    return __tvhserver;
}

- (TVHServerSettings*)serverSettings {
    return [self.settings currentServerSettings];
}

- (TVHSettings*)settings {
    if ( ! settings ) {
        settings = [TVHSettings sharedInstance];
    }
    return settings;
}

- (id<TVHModelAnalyticsProtocol>)analytics
{
    if ( ! _analytics ) {
        _analytics = [[TVHModelAnalytics alloc] init];
    }
    return _analytics;
}

#pragma mark Notifications

- (void)resetServer {
    [__tvhserver cancelAllOperations];
    __tvhserver = nil;
    settings = nil;
}

- (void)refreshServerVersion {
    NSString *serverVersion = __tvhserver.version;
    if ( ! [serverVersion isEqualToString:self.currentServerVersion] ) {
        [self changeCurrentServerVersionTo:serverVersion apiVersion:__tvhserver.apiVersion];
        [self resetServer];
    }
}

- (void)changeCurrentServerVersionTo:(NSString*)serverVersion apiVersion:(NSNumber*)apiVersion {
    NSMutableDictionary *prop = [[settings serverProperties:[settings selectedServer]] mutableCopy];
    [prop setValue:serverVersion forKey:TVHS_SERVER_VERSION];
    [prop setValue:apiVersion forKey:TVHS_API_VERSION];
    [settings setServerProperties:prop forServerId:[settings selectedServer]];
}

- (NSString*)currentServerVersion {
    return [self.settings currentServerProperty:TVHS_SERVER_VERSION];
}
@end
