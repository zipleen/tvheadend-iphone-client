//
//  TVHEpgStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
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

#import "TVHEpgStore.h"
#import "TVHEpg.h"
#import "TVHJsonClient.h"

@interface TVHEpgStore()
@property (nonatomic, strong) NSArray *epgStore;
@property (nonatomic, weak) id <TVHEpgStoreDelegate> delegate;
@property (nonatomic) NSInteger totalEventCount;
@property (nonatomic, strong) NSDate *profilingDate;
@end

@implementation TVHEpgStore

- (void)appWillEnterForeground:(NSNotification*)note {
    TVHEpg *last = [self.epgStore lastObject];
    if ( last && [last.start compare:[NSDate date]] == NSOrderedDescending ) {
        self.epgStore = nil;
        self.totalEventCount = 0;
        [self downloadEpgList];
    }
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetEpgStore)
                                                 name:@"resetAllObjects"
                                               object:nil];
    self.statsEpgName = @"Shared";
    return self;
}

- (id)initWithStatsEpgName:(NSString*)statsEpgName {
    self = [self init];
    if (!self) return nil;
    
    self.statsEpgName = statsEpgName;
    return self;
}

- (void)setStatsEpgName:(NSString *)statsEpgName {
    _statsEpgName = [NSString stringWithFormat:@"EpgStore-%@", statsEpgName];
}

- (NSArray*)epgStore {
    if ( !_epgStore ) {
        _epgStore = [[NSArray alloc] init];
    }
    return _epgStore;
}

- (void)resetEpgStore {
    self.epgStore = nil;
    self.filterToChannelName = nil;
    self.filterToProgramTitle = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.epgStore = nil;
}

- (void)addEpgItemToStore:(TVHEpg*)epgItem {
    // don't add duplicate items - need to search in the array!
    if ( [self.epgStore indexOfObject:epgItem] == NSNotFound ) {
        self.epgStore = [self.epgStore arrayByAddingObject:epgItem];
    }
}

- (void)fetchedData:(NSData *)responseData {
    
    NSError* error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:error];
    if( error ) {
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingEpgStore:)]) {
            [self.delegate didErrorLoadingEpgStore:error];
        }
        return ;
    }
    
    self.totalEventCount = [[json objectForKey:@"totalCount"] intValue];
    NSArray *entries = [json objectForKey:@"entries"];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHEpg *epg = [[TVHEpg alloc] init];
        [epg updateValuesFromDictionary:obj];
        [self addEpgItemToStore:epg];
    }];
    
#ifdef TESTING
    NSLog(@"[EpgStore: Loaded EPG programs (%@ | %@ | %d)]: %d", self.filterToChannelName, self.filterToProgramTitle, self.totalEventCount, [self.epgStore count]);
#endif
}

- (NSDictionary*)getPostParametersStartingFrom:(NSInteger)start limit:(NSInteger)limit {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%d", start ],
                                   @"start",
                                   [NSString stringWithFormat:@"%d", limit ],
                                   @"limit",nil];
    
    if( self.filterToChannelName != nil ) {
        [params setObject:self.filterToChannelName forKey:@"channel"];
    }
    
    if( self.filterToProgramTitle != nil ) {
        [params setObject:self.filterToProgramTitle forKey:@"title"];
    }
    
    return [params copy];
}

- (void)retrieveEpgDataFromTVHeadend:(NSInteger)start limit:(NSInteger)limit fetchAll:(BOOL)fetchAll {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    NSDictionary *params = [self getPostParametersStartingFrom:start limit:limit];
    self.profilingDate = [NSDate date];
    [httpClient postPath:@"/epg" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.profilingDate];
#ifdef TVH_GOOGLEANALYTICS_KEY
        [[GAI sharedInstance].defaultTracker sendTimingWithCategory:@"Network Profiling"
                                                          withValue:time
                                                           withName:self.statsEpgName
                                                          withLabel:nil];
#endif
#ifdef TESTING
        NSLog(@"[%@ Profiling Network]: %f", self.statsEpgName, time);
#endif
        [self fetchedData:responseObject];
        if ([self.delegate respondsToSelector:@selector(didLoadEpg:)]) {
            [self.delegate didLoadEpg:self];
        }
        
        [self getMoreEpg:start limit:limit fetchAll:fetchAll];
        
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[EpgStore HTTPClient Error]: %@", error.localizedDescription);
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingEpgStore:)]) {
            [self.delegate didErrorLoadingEpgStore:error];
        }
    }];
    
}

- (void)getMoreEpg:(NSInteger)start limit:(NSInteger)limit fetchAll:(BOOL)fetchAll {
    // get last epg
    // check date
    // if date > datenow, get more 50
    if ( fetchAll ) {
        if ( (start+limit) < self.totalEventCount ) {
            [self retrieveEpgDataFromTVHeadend:(start+limit) limit:300 fetchAll:true];
        }
    } else {
        TVHEpg *last = [self.epgStore lastObject];
        if ( last ) {
            NSDate *localDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    #ifdef TESTING
            //NSLog(@"localdate: %@ | last start date: %@ ", localDate, last.start);
    #endif
            if ( [localDate compare:last.start] == NSOrderedDescending && (start+limit) < self.totalEventCount ) {
                [self retrieveEpgDataFromTVHeadend:(start+limit) limit:50 fetchAll:false];
            }
        }
    }
}

- (void)downloadAllEpgItems {
    [self retrieveEpgDataFromTVHeadend:0 limit:300 fetchAll:true];
}

- (void)downloadEpgList {
    [self retrieveEpgDataFromTVHeadend:0 limit:50 fetchAll:false];
}

- (void)downloadMoreEpgList {
    [self retrieveEpgDataFromTVHeadend:[self.epgStore count] limit:50 fetchAll:false];
}

- (NSArray*)epgStoreItems{
    return self.epgStore;
}

- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)setFilterToProgramTitle:(NSString *)filterToProgramTitle {
    _filterToProgramTitle = filterToProgramTitle;
    self.epgStore = nil;
}

- (void)setFilterToChannelName:(NSString *)filterToChannelName {
    _filterToChannelName = filterToChannelName;
    self.epgStore = nil;
}

@end
