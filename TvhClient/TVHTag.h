//
//  TVHTag.h
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@class TVHServer;

@interface TVHTag : NSObject
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *icon;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (id)initWithAllChannels:(TVHServer*)tvhServer;
- (NSString*)idKey;
- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (NSInteger)channelCount;
@end
