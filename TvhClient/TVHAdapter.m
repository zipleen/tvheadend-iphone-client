//
//  TVHAdapters.m
//  TvhClient
//
//  Created by Luis Fernandes on 06/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAdapter.h"
#import "TVHServer.h"
#import "TVHMux.h"
#import "TVHService.h"

@interface TVHAdapter()
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@end

@implementation TVHAdapter

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
    return self;
}

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (NSArray*)arrayAdapterMuxes {
    id <TVHMuxStore> muxStore = [self.tvhServer muxStore];
    return [muxStore muxesFor:self];
}

- (NSArray*)arrayServicesForMux:(TVHMux*)adapterMux {
    id <TVHServiceStore> serviceStore = [self.tvhServer serviceStore];
    return [serviceStore servicesForMux:adapterMux];
}

- (NSString*)identifierForNetwork {
    return self.identifier;
}

@end
