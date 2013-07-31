//
//  TVHAdapters.m
//  TvhClient
//
//  Created by zipleen on 06/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAdapter.h"
#import "TVHServer.h"
#import "TVHAdapterMux.h"

@interface TVHAdapter()
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSArray *adapterMuxes;
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

#pragma MARK muxes stuff

- (BOOL)fetchedData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        NSLog(@"[TV Adapter Mux JSON error]: %@", error.localizedDescription);
        return false;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *muxes = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHAdapterMux *mux = [[TVHAdapterMux alloc] init];
        [mux setAdapterObject:self];
        [mux updateValuesFromDictionary:obj];
        
        [muxes addObject:mux];
    }];
    
    self.adapterMuxes = [muxes copy];
    
#ifdef TESTING
    NSLog(@"[Loaded Adapter Muxes]: %d", [self.adapterMuxes count]);
#endif
    return true;
}

- (void)fetchMuxes {
    NSString *muxPath = [@"dvb/muxes/" stringByAppendingString:self.identifier];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"get", @"op", nil];
    [self.jsonClient getPath:muxPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ( [self fetchedData:responseObject] ) {
            [self signalDidLoadAdapterMuxes];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[TV Adapter Mux HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}

- (NSArray*)arrayAdapterMuxes {
    return [self.adapterMuxes sortedArrayUsingSelector:@selector(compareByFreq:)];
}

- (void)signalDidLoadAdapterMuxes {
    
}


@end
