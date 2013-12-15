//
//  TVHModelAnalytics.m
//  TvhClient
//
//  Created by zipleen on 15/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHModelAnalytics.h"
#import "TVHAnalytics.h"
#import "TVHDebugLytics.h"

@implementation TVHModelAnalytics
- (void)sendEventWithCategory:(NSString *)category
                   withAction:(NSString *)action
                    withLabel:(NSString *)label
                    withValue:(NSNumber *)value
{
    [TVHAnalytics sendEventWithCategory:category withAction:action withLabel:label withValue:value];
}

- (void)sendTimingWithCategory:(NSString *)category
                     withValue:(NSTimeInterval)time
                      withName:(NSString *)name
                     withLabel:(NSString *)label
{
    [TVHAnalytics sendTimingWithCategory:category withValue:time withName:name withLabel:label];
}

- (void)setObjectValue:(id)value forKey:(NSString*)key
{
    [TVHDebugLytics setObjectValue:value forKey:key];
}

- (void)setIntValue:(int)value forKey:(NSString*)key
{
    [TVHDebugLytics setIntValue:value forKey:key];
}
@end
