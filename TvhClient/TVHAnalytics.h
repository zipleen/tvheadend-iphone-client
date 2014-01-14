//
//  TVHAnalytics.h
//  TvhClient
//
//  Created by Luis Fernandes on 24/10/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

#if defined TVH_GOOGLEANALYTICS_KEY
#define TVH_GOOGLEANALYTICS
#endif

@interface TVHAnalytics : NSObject
+ (void)start;
+ (void)setOptOut:(BOOL)optOut;
+ (void)sendView:(NSString*)message;
+ (void)sendEventWithCategory:(NSString *)category
                   withAction:(NSString *)action
                    withLabel:(NSString *)label
                    withValue:(NSNumber *)value;
+ (void)sendTimingWithCategory:(NSString *)category
                     withValue:(NSTimeInterval)time
                      withName:(NSString *)name
                     withLabel:(NSString *)label;
@end
