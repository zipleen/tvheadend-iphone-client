//
//  TVHStatusSubscription.h
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/18/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@interface TVHStatusSubscription : NSObject
@property (strong, nonatomic) NSString *channel;
@property NSInteger errors;
@property (strong, nonatomic) NSString *hostname;
@property NSInteger id;
@property (strong, nonatomic) NSString *service;
@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *title;
@property NSInteger bw;

// 4.0
@property NSInteger in;
@property NSInteger out;

- (void)updateValuesFromDictionary:(NSDictionary*) values;
@end
