//
//  TVHAdapters.m
//  TvhClient
//
//  Created by zipleen on 06/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHAdapter.h"

@implementation TVHAdapter

- (void) updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

@end
