//
//  TVHConfigNames.m
//  TvhClient
//
//  Created by zipleen on 7/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHConfigName.h"

@implementation TVHConfigName

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (BOOL)isEqual: (id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    TVHConfigName *otherCast = other;
    return [self.name isEqualToString:otherCast.name];
}


@end
