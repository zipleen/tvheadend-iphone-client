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
    });
    
    return __sharedInstance;
}

+ (TVHServer*)sharedServerInstance {
    return [[TVHSingletonServer sharedInstance] serverInstance];
}

- (TVHServer*)serverInstance {
    if ( ! __tvhserver ) {
        __tvhserver = [[TVHServer alloc] initVersion:@"3.4"];
    }
    return __tvhserver;
}

- (void)resetServer {
    __tvhserver = nil;
}
@end
