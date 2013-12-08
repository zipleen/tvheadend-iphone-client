//
//  TVHConfigNames.h
//  TvhClient
//
//  Created by Luis Fernandes on 7/17/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@interface TVHConfigName : NSObject
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;

- (void)updateValuesFromDictionary:(NSDictionary*) values;

@end
