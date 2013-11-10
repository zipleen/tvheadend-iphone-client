//
//  TVHAdapterMux.m
//  TvhClient
//
//  Created by zipleen on 30/07/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAdapterMux.h"
#import "TVHService.h"

@interface TVHAdapterMux()
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSArray *services;
@end

@implementation TVHAdapterMux

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDvbMux:)
                                                 name:@"dvbMuxNotificationClassReceived"
                                               object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (NSComparisonResult)compareByFreq:(TVHAdapterMux *)otherObject {
    return [self.freq compare:otherObject.freq];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    TVHAdapterMux *otherCast = other;
    return self.id == otherCast.id;
}

- (void)updateDvbMux:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"dvbMuxNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        if ( [self.id isEqualToString:[message objectForKey:@"id"]] ) {
            [message enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self setValue:obj forKey:key];
            }];
            
            // signal table update
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didRefreshAdapterMux"
                                                                object:self];
        }
    }
}

@end
