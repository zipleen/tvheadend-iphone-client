//
//  TVHTag.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHTag.h"

@implementation TVHTag

- (void)dealloc {
    self.name = nil;
    self.comment = nil;
    self.icon = nil;
}

- (id)initWithAllChannels {
    self = [super init];
    if (self) {
        self.id = 0;
        self.name = NSLocalizedString(@"All Channels", nil);

    }
    return self;
}

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (NSComparisonResult)compareByName:(TVHTag *)otherObject {
    return [self.name compare:otherObject.name];
}

- (BOOL)isEqual: (id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    TVHTag *otherCast = other;
    return self.id == otherCast.id;
}
@end
