//
//  NSArray+Utils.m
//  TvhClient
//
//  Created by zipleen on 04/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
