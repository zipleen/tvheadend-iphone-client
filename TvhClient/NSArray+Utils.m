//
//  NSArray+Utils.m
//  TvhClient
//
//  Created by Luis Fernandes on 04/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "NSArray+Utils.h"

@implementation NSArray(NSArrayUtils)
- (NSArray*)convertObjectsToStrings {
    NSMutableArray *stringArray = [[NSMutableArray alloc] init];
    for (id obj in self) {
        [stringArray addObject:[NSString stringWithFormat:@"%@", obj]];
    }
    return [stringArray copy];
}
@end
