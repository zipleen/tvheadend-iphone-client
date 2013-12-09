//
//  TVHServiceStore.m
//  TvhClient
//
//  Created by Luis Fernandes on 08/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHServiceStoreAbstract.h"
#import "TVHService.h"
#import "TVHMux.h"
#import "TVHServer.h"

@interface TVHServiceStoreAbstract()
@property (nonatomic, weak) TVHApiClient *apiClient;
@property (nonatomic, strong) NSArray *services;
@end

@implementation TVHServiceStoreAbstract

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.apiClient = [self.tvhServer apiClient];
    return self;
}

- (NSArray*)services {
    if ( !_services ) {
        _services = [[NSArray alloc] init];
    }
    return _services;
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

- (void)fetchServices {
    TVHServiceStoreAbstract __weak *weakSelf = self;
    
    [self.apiClient doApiCall:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ( [weakSelf fetchedServiceData:responseObject] ) {
            [weakSelf signalDidLoadServices];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[TV Services HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}

- (BOOL)fetchedServiceData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        NSLog(@"[TV Service Channel JSON error]: %@", error.localizedDescription);
        return false;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHService *service = [[TVHService alloc] initWithTvhServer:self.tvhServer];
        [service updateValuesFromDictionary:obj];
        
        if ( [self addServiceToStore:service] == NO ) {
            [self updateServiceFromStore:service];
        }
    }];
    
#ifdef TESTING
    NSLog(@"[Loaded Services]: %d", [self.services count]);
#endif
    return true;
}

- (BOOL)addServiceToStore:(TVHService*)serviceItem {
    if ( [self.services indexOfObject:serviceItem] == NSNotFound ) {
        self.services = [self.services arrayByAddingObject:serviceItem];
        return YES;
    }
    return NO;
}

- (BOOL)updateServiceFromStore:(TVHService*)serviceItem {
    if ( [self.services indexOfObject:serviceItem] != NSNotFound ) {
        TVHService *foundService = [self.services objectAtIndex:[self.services indexOfObject:serviceItem]];
        [foundService updateValuesFromService:serviceItem];
        return YES;
    }
    return NO;
}

- (NSArray*)servicesForMux:(TVHMux*)adapterMux {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mux == %@ AND satconf == %@ AND network == %@", adapterMux.freq, adapterMux.satconf, adapterMux.network];
    NSArray *filteredArray = [self.services filteredArrayUsingPredicate:predicate];
    
    return [filteredArray sortedArrayUsingSelector:@selector(compareByName:)];
}

- (void)signalDidLoadServices {
    
}

@end
