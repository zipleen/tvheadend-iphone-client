//
//  TVHAutoRecItem.m
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
