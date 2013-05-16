//
//  TVHSingletonServer.m
//  TvhClient
//
//  Created by zipleen on 16/05/2013.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHSingletonServer.h"

@implementation TVHSingletonServer

+ (TVHServer*)sharedServerInstance {
    static TVHServer *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHServer alloc] init];
    });
    
    return __sharedInstance;
}

@end
