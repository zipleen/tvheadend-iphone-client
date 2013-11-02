//
//  TVHAutoRecStore.m
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAutoRecStore.h"
#import "TVHServer.h"

@interface TVHAutoRecStore()
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSArray *dvrAutoRecItems;
@property (nonatomic, strong) NSDate *profilingDate;
@end

@implementation TVHAutoRecStore

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAutoRecNotification:)
                                                 name:@"autorecNotificationClassReceived"
                                               object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.dvrAutoRecItems = nil;
}

- (void)receiveAutoRecNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"autorecNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        if ( [[message objectForKey:@"reload"] intValue] == 1 ) {
            [self fetchDvrAutoRec];
        }
    }
}

- (void)fetchedData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        [self signalDidErrorDvrAutoStore:error];
        return ;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *dvrAutoRecItems = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHAutoRecItem *dvritem = [[TVHAutoRecItem alloc] initWithJsonClient:[self.tvhServer jsonClient]];
        [dvritem updateValuesFromDictionary:obj];
        
        [dvrAutoRecItems addObject:dvritem];
    }];
    
    self.dvrAutoRecItems = [dvrAutoRecItems copy];
    
#ifdef TESTING
    NSLog(@"[Loaded Auto Rec Items, Count]: %d", [self.dvrAutoRecItems count]);
#endif
    [TVHDebugLytics setIntValue:[self.dvrAutoRecItems count] forKey:@"autorec"];
}

- (void)fetchDvrAutoRec {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"get", @"op", @"autorec", @"table", nil];
    self.dvrAutoRecItems = nil;
    self.profilingDate = [NSDate date];
    [self.jsonClient getPath:@"tablemgr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.profilingDate];
        [TVHAnalytics sendTimingWithCategory:@"Network Profiling"
                                                          withValue:time
                                                           withName:@"AutoRec"
                                                          withLabel:nil];
#ifdef TESTING
        NSLog(@"[AutoRec Profiling Network]: %f", time);
#endif
        [self fetchedData:responseObject];
        [self signalDidLoadDvrAutoRec];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self signalDidErrorDvrAutoStore:error];
        NSLog(@"[DVR AutoRec Items HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}

- (TVHAutoRecItem *)objectAtIndex:(int)row {
    if ( row < [self.dvrAutoRecItems count] ) {
        return [self.dvrAutoRecItems objectAtIndex:row];
    }
    return nil;
}

- (int)count {
    if ( self.dvrAutoRecItems ) {
        return [self.dvrAutoRecItems count];
    }
    return 0;
}

- (void)signalWillLoadDvrAutoRec {
    if ([self.delegate respondsToSelector:@selector(willLoadDvrAutoRec)]) {
        [self.delegate willLoadDvrAutoRec];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willLoadDvrAutoRec"
                                                        object:self];
}

- (void)signalDidLoadDvrAutoRec {
    if ([self.delegate respondsToSelector:@selector(didLoadDvrAutoRec)]) {
        [self.delegate didLoadDvrAutoRec];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadDvrAutoRec"
                                                        object:self];
}

- (void)signalDidErrorDvrAutoStore:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorDvrAutoStore:)]) {
        [self.delegate didErrorDvrAutoStore:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didErrorDvrAutoStore"
                                                        object:error];
}

@end
