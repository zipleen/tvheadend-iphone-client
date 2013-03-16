//
//  TVHTag.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHTag.h"

@implementation TVHTag

-(id) initWithAllChannels {
    self = [super init];
    if (self) {
        self.id = 0;
        self.name = NSLocalizedString(@"All Channels", nil);

    }
    return self;
}

- (void) updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (NSComparisonResult)compareByName:(TVHTag *)otherObject {
    return [self.name compare:otherObject.name];
}
@end
