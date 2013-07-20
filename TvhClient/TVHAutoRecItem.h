//
//  TVHAutoRecItem.h
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@class TVHJsonClient;

@interface TVHAutoRecItem : NSObject
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *config_name;
@property (nonatomic) NSInteger contenttype;
@property (nonatomic) NSInteger approx_time; // approx_time in minutes
@property (nonatomic, strong) NSString *creator;
@property (nonatomic) NSInteger enabled;
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *pri;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *weekdays; // mon 1, sun 7
@property (nonatomic) NSInteger serieslink;
@property (nonatomic, weak) TVHJsonClient *jsonClient;
- (id)initWithJsonClient:(TVHJsonClient*)jsonClient;
- (void)updateValue:(id)value forKey:(NSString*)key;
- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (void)deleteAutoRec;
- (NSString*)stringFromAproxTime;
+ (NSString*)stringFromMinutes:(int)minutes;
- (void)updateAutoRec;
@end
