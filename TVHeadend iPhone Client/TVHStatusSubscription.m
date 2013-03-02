//
//  TVHStatusSubscription.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHStatusSubscription.h"

@implementation TVHStatusSubscription

-(void)setStart:(id)startDate {
    if([startDate isKindOfClass:[NSString class]]) {
        _start = [NSDate dateWithTimeIntervalSince1970:[startDate intValue]];
    }
}

- (void) updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

@end
