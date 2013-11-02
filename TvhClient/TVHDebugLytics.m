//
//  TVHDebugLytics.m
//  TvhClient
//
//  Created by zipleen on 01/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDebugLytics.h"
#import <Crashlytics/Crashlytics.h>

@implementation TVHDebugLytics

+ (void)setObjectValue:(id)value forKey:(NSString*)key {
#if defined TVH_CRASHLYTICS_KEY
    [Crashlytics setObjectValue:value forKey:key];
#endif
}

+ (void)setIntValue:(int)value forKey:(NSString*)key {
#if defined TVH_CRASHLYTICS_KEY
    [Crashlytics setIntValue:value forKey:key];
#endif
}

@end
