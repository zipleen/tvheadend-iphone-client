//
//  TVHAutoRecItem.h
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@property (nonatomic, strong) NSString *weekdays; // mon 1, sun 7

- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (void)deleteAutoRec;
@end
