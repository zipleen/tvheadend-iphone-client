//
//  TVHAdapterMux.m
//  TvhClient
//
//  Created by Luis Fernandes on 30/07/13.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHServer.h"
#import "TVHMux.h"
#import "TVHService.h"

@interface TVHMux()
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSArray *services;
@end

@implementation TVHMux

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

- (void)updateValuesFromTVHMux:(TVHMux *)mux {
    self.network = mux.network;
    self.uuid = mux.uuid;
    self.enabled = mux.enabled;
    self.onid = mux.onid;
    self.name = mux.name;
    self.delsys = mux.delsys;
    self.frequency = mux.frequency;
    self.bandwidth = mux.bandwidth;
    self.constellation = mux.constellation;
    self.transmission_mode = mux.transmission_mode;
    self.guard_interval = mux.guard_interval;
    self.hierarchy = mux.hierarchy;
    self.fec_hi = mux.fec_hi;
    self.fec_lo = mux.fec_lo;
    self.tsid = mux.tsid;
    self.initscan = mux.initscan;
    self.num_svc = mux.num_svc;
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (NSComparisonResult)compareByFreq:(TVHMux *)otherObject {
    return [self.freq compare:otherObject.freq];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    TVHMux *otherCast = other;
    if ( self.id == otherCast.id
        && [self.network isEqualToString:otherCast.network] 
        && [self.uuid isEqualToString:otherCast.uuid] ) {
        return YES;
    }
    return NO;
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
