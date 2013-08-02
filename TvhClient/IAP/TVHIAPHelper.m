//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "TVHIAPHelper.h"

@implementation TVHIAPHelper

+ (TVHIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static TVHIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.zipleen.TvhClient.1thanksllama",
                                      @"com.zipleen.TvhClient.2thankssloth",
                                      @"com.zipleen.TvhClient.3thankswale",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
