//
//  TVHModelAnalytics.h
//  TvhClient
//
//  Created by zipleen on 15/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@protocol TVHModelAnalyticsProtocol <NSObject>
- (void)sendEventWithCategory:(NSString *)category
                   withAction:(NSString *)action
                    withLabel:(NSString *)label
                    withValue:(NSNumber *)value;
- (void)sendTimingWithCategory:(NSString *)category
                     withValue:(NSTimeInterval)time
                      withName:(NSString *)name
                     withLabel:(NSString *)label;
- (void)setObjectValue:(id)value forKey:(NSString*)key;
- (void)setIntValue:(int)value forKey:(NSString*)key;
@end
