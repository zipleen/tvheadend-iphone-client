//
//  TVHSingletonServer.m
//  TvhClient
//
//  Created by zipleen on 16/05/2013.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHSingletonServer.h"

@implementation TVHSingletonServer {
    TVHServer *__tvhserver;
    TVHSettings *settings;
}

+ (TVHSingletonServer*)sharedInstance {
    static TVHSingletonServer *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHSingletonServer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:__sharedInstance
                                                 selector:@selector(resetServer)
                                                     name:@"resetAllObjects"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:__sharedInstance
                                                 selector:@selector(refreshServerVersion)
                                                     name:@"didLoadTVHVersion"
                                                   object:nil];
    });
    
    return __sharedInstance;
}

+ (TVHServer*)sharedServerInstance {
    return [[TVHSingletonServer sharedInstance] serverInstance];
}

- (TVHSettings*)settings {
    if ( ! settings ) {
        settings = [TVHSettings sharedInstance];
    }
    return settings;
}

- (NSString*)serverVersion {
    return [self.settings currentServerProperty:TVHS_SERVER_VERSION];
}

- (void)refreshServerVersion {
    NSString *serverVersion = [__tvhserver version];
    if ( ! [serverVersion isEqualToString:[self serverVersion]] ) {
        NSMutableDictionary *prop = [[settings serverProperties:[settings selectedServer]] mutableCopy];
        [prop setValue:serverVersion forKey:TVHS_SERVER_VERSION];
        [settings setServerProperties:prop forServerId:[settings selectedServer]];
        [self resetServer];
    }
}

- (TVHServer*)serverInstance {
    if ( ! __tvhserver ) {
        __tvhserver = [[TVHServer alloc] initVersion:[self serverVersion]];
    }
    return __tvhserver;
}

- (void)resetServer {
    __tvhserver = nil;
}
@end
