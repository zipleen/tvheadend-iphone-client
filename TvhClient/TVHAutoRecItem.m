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

- (void)dealloc {
    self.channel = nil;
    self.comment = nil;
    self.config_name = nil;
    self.creator = nil;
    self.pri = nil;
    self.title = nil;
    self.tag = nil;
    self.weekdays = nil;
}

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (void)deleteAutoRec {
    [TVHTableMgrActions doTableMgrAction:@"delete" inTable:@"autorec" withEntries:@[ [NSString stringWithFormat:@"\"%d\"",self.id] ] ];
}
@end
