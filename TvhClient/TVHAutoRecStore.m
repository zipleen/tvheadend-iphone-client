//
//  TVHAutoRecStore.m
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
        TVHAutoRecItem *dvritem = [[TVHAutoRecItem alloc] init];
        [dvritem updateValuesFromDictionary:obj];
        
        [dvrAutoRecItems addObject:dvritem];
    }];
    
    self.dvrAutoRecItems = [dvrAutoRecItems copy];
    
#ifdef TESTING
    NSLog(@"[Loaded Auto Rec Items, Count]: %d", [self.dvrAutoRecItems count]);
#endif
}

- (void)fetchDvrAutoRec {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"get", @"op", @"autorec", @"table", nil];
    self.dvrAutoRecItems = nil;
    self.profilingDate = [NSDate date];
    [self.jsonClient getPath:@"tablemgr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.profilingDate];
#ifdef TVH_GOOGLEANALYTICS_KEY
        [[GAI sharedInstance].defaultTracker sendTimingWithCategory:@"Network Profiling"
                                                          withValue:time
                                                           withName:@"AutoRec"
                                                          withLabel:nil];
#endif
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
