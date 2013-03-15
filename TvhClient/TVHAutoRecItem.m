//
//  TVHAutoRecItem.m
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHAutoRecItem.h"
#import "TVHTableMgrActions.h"

@implementation TVHAutoRecItem
- (void) updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

-(void)deleteAutoRec {
    [TVHTableMgrActions doTableMgrAction:@"delete" inTable:@"autorec" withEntries:@[ [NSString stringWithFormat:@"\"%d\"",self.id] ] ];
}
@end
