//
//  TVHMuxStore.m
//  TvhClient
//
//  Created by Luis Fernandes on 08/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHMuxStoreAbstract.h"
#import "TVHMux.h"
#import "TVHServer.h"

@interface TVHMuxStoreAbstract()
@property (nonatomic, weak) TVHApiClient *apiClient;
@property (nonatomic, strong) NSArray *muxes;
@end

@implementation TVHMuxStoreAbstract

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.apiClient = [self.tvhServer apiClient];
    return self;
}

- (NSArray*)muxes {
    if ( !_muxes ) {
        _muxes = [[NSArray alloc] init];
    }
    return _muxes;
}

#pragma mark Api Client delegates

- (NSString*)apiMethod {
    return nil;
}

- (NSString*)apiPath {
    return nil;
}

- (NSDictionary*)apiParameters {
    return nil;
}

- (void)fetchMuxes {
    TVHMuxStoreAbstract __weak *weakSelf = self;
    
    [self.apiClient doApiCall:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ( [weakSelf fetchedData:responseObject] ) {
            [weakSelf signalDidLoadAdapterMuxes];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[TV Adapter Mux HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}

- (BOOL)fetchedData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        NSLog(@"[Mux JSON error]: %@", error.localizedDescription);
        return false;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHMux *mux = [[TVHMux alloc] initWithTvhServer:self.tvhServer];
        [mux updateValuesFromDictionary:obj];
        
        if ( [self addMuxToStore:mux] == NO ) {
            [self updateMuxFromStore:mux];
        }
    }];
    
#ifdef TESTING
    NSLog(@"[Loaded Adapter Muxes]: %d", [self.muxes count]);
#endif
    return true;
}

- (BOOL)addMuxToStore:(TVHMux*)muxItem {
    if ( [self.muxes indexOfObject:muxItem] == NSNotFound ) {
        self.muxes = [self.muxes arrayByAddingObject:muxItem];
        return YES;
    }
    return NO;
}

- (BOOL)updateMuxFromStore:(TVHMux*)muxItem {
    if ( [self.muxes indexOfObject:muxItem] != NSNotFound ) {
        TVHMux *foundMux = [self.muxes objectAtIndex:[self.muxes indexOfObject:muxItem]];
        [foundMux updateValuesFromTVHMux:muxItem];
        return YES;
    }
    return NO;
}

- (NSArray*)muxesFor:(id <TVHMuxNetwork>)network {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adapterId == %@", [network identifierForNetwork]];
    NSArray *filteredArray = [self.muxes filteredArrayUsingPredicate:predicate];
    
    return [filteredArray sortedArrayUsingSelector:@selector(compareByFreq:)];
}

- (void)signalDidLoadAdapterMuxes {
    
}

@end
