//
//  TVHDvrStore.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 28/02/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHDvrStoreAbstract.h"
#import "TVHServer.h"

@interface TVHDvrStoreAbstract()
@property (nonatomic, weak) TVHApiClient *apiClient;
@property (nonatomic) NSInteger cachedType;
@property (nonatomic, strong) NSMutableArray *totalEventCount;

@property NSInteger filterStart;
@property NSInteger filterLimit;
@property (nonatomic, strong) NSString *filterPath;
@end

@implementation TVHDvrStoreAbstract

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.apiClient = [self.tvhServer apiClient];
    
    self.cachedType = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDvrdbNotification:)
                                                 name:@"dvrdbNotificationClassReceived"
                                               object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.dvrItems = nil;
    self.cachedDvrItems = nil;
}

- (void)receiveDvrdbNotification:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"dvrdbNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        if ( [[message objectForKey:@"reload"] intValue] == 1 ) {
            [self fetchDvr];
        }
    }
}

- (NSMutableArray*)totalEventCount {
    if ( !_totalEventCount ) {
        _totalEventCount = [@[@0,@0,@0,@0] mutableCopy];
    }
    return _totalEventCount;
}

- (NSArray*)dvrItems {
    if ( !_dvrItems ) {
        _dvrItems = [[NSArray alloc] init];
    }
    return _dvrItems;
}

- (void)addDvrItemToStore:(TVHDvrItem*)dvritem {
    // don't add duplicate items - need to search in the array!
    if ( [self.dvrItems indexOfObject:dvritem] == NSNotFound ) {
        self.dvrItems = [self.dvrItems arrayByAddingObject:dvritem];
    }
}

- (TVHDvrItem*)createDvrItemFromDictionary:(NSDictionary*)obj ofType:(NSInteger)type {
    TVHDvrItem *dvritem = [[TVHDvrItem alloc] init];
    [dvritem updateValuesFromDictionary:obj];
    [dvritem setDvrType:type];
    return dvritem;
}

- (bool)fetchedData:(NSData *)responseData withType:(NSInteger)type {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        [self signalDidErrorDvrStore:error];
        return false;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSNumber *totalCount = [[NSNumber alloc] initWithInt:[[json objectForKey:@"totalCount"] intValue]];
    [self.totalEventCount replaceObjectAtIndex:type withObject:totalCount];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHDvrItem *dvritem = [self createDvrItemFromDictionary:obj ofType:type];
        [self addDvrItemToStore:dvritem];
    }];
    
#ifdef TESTING
    NSLog(@"[Loaded DVR Items, Count]: %d", [self.dvrItems count]);
#endif
    [TVHDebugLytics setIntValue:[self.dvrItems count] forKey:[NSString stringWithFormat:@"dvr_%d", type]];
    return true;
}

#pragma mark Api Client delegates

- (NSString*)apiMethod {
    return @"GET";
}

- (NSString*)apiPath {
    return self.filterPath;
}

- (NSDictionary*)apiParameters {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%d", self.filterStart ],
                                   @"start",
                                   [NSString stringWithFormat:@"%d", self.filterLimit ],
                                   @"limit",nil];
}

- (void)fetchDvrItemsFromServer:(NSString*)url withType:(NSInteger)type start:(NSInteger)start limit:(NSInteger)limit {
    [self signalWillLoadDvr:type];
    __block NSDate *profilingDate = [NSDate date];
    TVHDvrStoreAbstract __weak *weakSelf = self;
    
    self.filterPath = url;
    self.filterStart = start;
    self.filterLimit = limit;
    
    [self.apiClient doApiCall:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:profilingDate];
        [TVHAnalytics sendTimingWithCategory:@"Network Profiling"
                                   withValue:time
                                    withName:[NSString stringWithFormat:@"DvrStore-%d", type]
                                   withLabel:nil];
#ifdef TESTING
        NSLog(@"[DvrStore Profiling Network]: %f", time);
#endif

        if ( [weakSelf fetchedData:responseObject withType:type] ) {
            [weakSelf signalDidLoadDvr:type];
            [weakSelf getMoreDvrItems:url withType:type start:start limit:limit];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf signalDidErrorDvrStore:error];
        NSLog(@"[DVR Items HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}

- (void)getMoreDvrItems:(NSString*)url withType:(NSInteger)type start:(NSInteger)start limit:(NSInteger)limit {
    if ( (start+limit) < [[self.totalEventCount objectAtIndex:type] intValue] ) {
        [self fetchDvrItemsFromServer:url withType:type start:(start+limit) limit:limit];
    }
}

- (void)fetchDvr {
    self.dvrItems = nil;
    self.cachedDvrItems = nil;
    
    [self fetchDvrItemsFromServer:@"dvrlist_upcoming" withType:RECORDING_UPCOMING start:0 limit:20];
    [self fetchDvrItemsFromServer:@"dvrlist_finished" withType:RECORDING_FINISHED start:0 limit:20];
    [self fetchDvrItemsFromServer:@"dvrlist_failed" withType:RECORDING_FAILED start:0 limit:20];
}

- (NSArray*)dvrItemsForType:(NSInteger)type {
    NSMutableArray *itemsForType = [[NSMutableArray alloc] init];
    
    [self.dvrItems enumerateObjectsUsingBlock:^(TVHDvrItem* item, NSUInteger idx, BOOL *stop) {
        if ( item.dvrType == type ) {
            [itemsForType addObject:item];
        }
    }];
    self.cachedType = -1;
    self.cachedDvrItems = nil;
    return [itemsForType copy];
}

- (void)checkCachedDvrItemsForType:(NSInteger)type {
    if( self.cachedType != type ) {
        self.cachedType = type;
        self.cachedDvrItems = [self dvrItemsForType:type];
    }
}

- (TVHDvrItem *)objectAtIndex:(int)row forType:(NSInteger)type{
    [self checkCachedDvrItemsForType:type];
    
    if ( row < [self.cachedDvrItems count] ) {
        return [self.cachedDvrItems objectAtIndex:row];
    }
    return nil;
}

- (int)count:(NSInteger)type {
    [self checkCachedDvrItemsForType:type];
    
    if ( self.cachedDvrItems ) {
        return [self.cachedDvrItems count];
    }
    return 0;
}

#pragma mark Signal delegate

- (void)signalWillLoadDvr:(NSInteger)type {
    if ([self.delegate respondsToSelector:@selector(willLoadDvr:)]) {
        [self.delegate willLoadDvr:type];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willLoadDvr"
                                                        object:self];
}

- (void)signalDidLoadDvr:(NSInteger)type {
    if ([self.delegate respondsToSelector:@selector(didLoadDvr:)]) {
        [self.delegate didLoadDvr:type];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadDvr"
                                                        object:self];
}

- (void)signalDidErrorDvrStore:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorDvrStore:)]) {
        [self.delegate didErrorDvrStore:error];
    }
}

@end
