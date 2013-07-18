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

@interface TVHAutoRecItem ()
@property (nonatomic, strong) NSMutableArray *updatedProperties;
@end

@implementation TVHAutoRecItem

- (id)initWithJsonClient:(TVHJsonClient*)jsonClient {
    self = [super init];
    if (!self) return nil;
    self.jsonClient = jsonClient;
    
    return self;
}

- (NSMutableArray*)updatedProperties {
    if ( ! _updatedProperties ) {
        _updatedProperties = [[NSMutableArray alloc] init];
    }
    return _updatedProperties;
}

- (id)copyWithZone:(NSZone *)zone {
    TVHAutoRecItem *item = [[[self class] allocWithZone:zone] init];
    item.channel = self.channel;
    item.comment = self.comment;
    item.contenttype = self.contenttype;
    item.config_name = self.config_name;
    item.approx_time = self.approx_time;
    item.enabled = self.enabled;
    item.id = self.id;
    item.creator = self.creator;
    item.pri = self.pri;
    item.title = self.title;
    item.tag = self.tag;
    item.weekdays = self.weekdays;
    item.genre = self.genre;
    return item;
}

- (void)updateValue:(id)value forKey:(NSString*)key {
    [self setValue:value forKey:key];
    [self.updatedProperties addObject:key];
}

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

+ (NSString*)stringFromMinutes:(int)dayMinutes {
    return [NSString stringWithFormat:@"%d:%02d", (int)(dayMinutes/60), (int)(dayMinutes%60) ];
}

- (NSString*)stringFromAproxTime {
    if ( self.approx_time == 0 ) {
        return nil;
    }
    return [TVHAutoRecItem stringFromMinutes:self.approx_time];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (void)deleteAutoRec {
    [TVHTableMgrActions doTableMgrAction:@"delete" withJsonClient:self.jsonClient inTable:@"autorec" withEntries:[NSString stringWithFormat:@"%d",self.id] ];
}

- (void)updateAutoRec {
    if ( [self.updatedProperties count] == 0 ) {
        return;
    }
    
    NSMutableDictionary *sendProperties = [[NSMutableDictionary alloc] init];
    for (NSString* key in self.updatedProperties) {
        [sendProperties setValue:[self valueForKey:key] forKey:key];
    }
    [sendProperties setValue:[NSString stringWithFormat:@"%d", self.id] forKey:@"id"];
    [TVHTableMgrActions doTableMgrAction:@"update" withJsonClient:self.jsonClient inTable:@"autorec" withEntries:sendProperties ];
}
@end
