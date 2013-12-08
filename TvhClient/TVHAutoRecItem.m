//
//  TVHAutoRecItem.m
//  TvhClient
//
//  Created by Luis Fernandes on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAutoRecItem.h"
#import "TVHTableMgrActions.h"
#import "TVHServer.h"

@interface TVHAutoRecItem ()
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSMutableArray *updatedProperties;
@end

@implementation TVHAutoRecItem

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
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

- (void)setWeekdays:(id)weekdays {
    if([weekdays isKindOfClass:[NSString class]]) {
        _weekdays = [weekdays componentsSeparatedByString:@","];
    }
    if([weekdays isKindOfClass:[NSArray class]]) {
        _weekdays = weekdays;
    }
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
