//
//  TVHAnalytics.h
//  TvhClient
//
//  Created by zipleen on 24/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

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
