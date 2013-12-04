//
//  TVHEpgStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHEpgStoreAbstract.h"
#import "TVHEpg.h"
#import "TVHServer.h"

@interface TVHEpgStoreAbstract()
@property (nonatomic, strong) TVHApiClient *apiClient;
@property (nonatomic, strong) NSArray *epgStore;
@property (nonatomic, weak) id <TVHEpgStoreDelegate> delegate;
@property (nonatomic) NSInteger totalEventCount;

@end

@implementation TVHEpgStoreAbstract

- (void)appWillEnterForeground:(NSNotification*)note {
    [self removeOldProgramsFromStore];
    
    if ( [self isLastEpgFromThePast] ) {
        self.epgStore = nil;
        self.totalEventCount = 0;
        [self downloadEpgList];
    }
}

- (void)removeOldProgramsFromStore {
    BOOL __block didRemove = false;
    NSMutableArray *myStore = [[NSMutableArray alloc ] init];
    if ( self.epgStore ) {
        for ( TVHEpg *obj in self.epgStore ) {
            if ( [obj progress] >= 1.0 ) {
                didRemove = true;
            } else {
                [myStore addObject:obj];
            }
        }
    }
    if ( didRemove ) {
        self.epgStore = [myStore copy];
        [self signalDidLoadEpg];
    }
}

- (BOOL)isLastEpgFromThePast {
    TVHEpg *last = [self.epgStore lastObject];
    return ( last && [last.start compare:[NSDate date]] == NSOrderedDescending );
}

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.apiClient = [self.tvhServer apiClient];
    
    self.statsEpgName = @"Shared";
    return self;
}

- (id)initWithStatsEpgName:(NSString*)statsEpgName withTvhServer:(TVHServer*)tvhServer {
    self = [self initWithTvhServer:tvhServer];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.epgStore = nil;
    self.filterToChannelName = nil;
    self.filterToProgramTitle = nil;
    self.filterToTagName = nil;
}

- (void)addEpgItemToStore:(TVHEpg*)epgItem {
    // don't add duplicate items - need to search in the array!
    if ( [self.epgStore indexOfObject:epgItem] == NSNotFound ) {
        self.epgStore = [self.epgStore arrayByAddingObject:epgItem];
    }
#ifdef TESTING
    else {
        NSLog(@"[EpgStore-%@: duplicate EPG: %@", self.statsEpgName, [epgItem title] );
    }
#endif
}

#pragma mark ApiClient Implementation

- (NSString*)jsonApiFieldEntries {
    return @"entries";
}

- (bool)fetchedData:(NSData *)responseData {
    
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingEpgStore:)]) {
            [self.delegate didErrorLoadingEpgStore:error];
        }
        return false;
    }
    
    self.totalEventCount = [[json objectForKey:@"totalCount"] intValue];
    NSArray *entries = [json objectForKey:self.jsonApiFieldEntries];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHEpg *epg = [[TVHEpg alloc] initWithTvhServer:self.tvhServer];
        [epg updateValuesFromDictionary:obj];
        [self addEpgItemToStore:epg];
    }];
    
#ifdef TESTING
    NSLog(@"[%@: Loaded EPG programs (ch:%@ | pr:%@ | tag:%@ | evcount:%d)]: %d", self.statsEpgName, self.filterToChannelName, self.filterToProgramTitle, self.filterToTagName, self.totalEventCount, [self.epgStore count]);
#endif
    return true;
}

- (NSDictionary*)apiParameters {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%d", self.filterStart ],
                                   @"start",
                                   [NSString stringWithFormat:@"%d", self.filterLimit ],
                                   @"limit",nil];
    
    if( self.filterToChannelName != nil ) {
        [params setObject:self.filterToChannelName forKey:@"channel"];
    }
    
    if( self.filterToProgramTitle != nil ) {
        [params setObject:self.filterToProgramTitle forKey:@"title"];
    }
    
    if( self.filterToTagName != nil ) {
        [params setObject:self.filterToTagName forKey:@"tag"];
    }
    
    if( self.filterToContentTypeId != nil ) {
        [params setObject:self.filterToContentTypeId forKey:@"contenttype"];
    }
    
    return [params copy];
}

- (NSString*)apiPath {
    return @"epg";
}

- (NSString*)apiMethod {
    return @"POST";
}

- (void)retrieveEpgDataFromTVHeadend:(NSInteger)start limit:(NSInteger)limit fetchAll:(BOOL)fetchAll {
    
    self.filterStart = start;
    self.filterLimit = limit;
    
    [self signalWillLoadEpg];
#ifdef TESTING
    NSLog(@"[%@ EPG Going to call (total event count:%d)]: %@", self.statsEpgName, self.totalEventCount, self.apiParameters);
#endif
    TVHEpgStoreAbstract __weak *weakSelf = self;
    
    __block NSDate *profilingDate = [NSDate date];
    [self.apiClient doApiCall:self
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if( ! (weakSelf.filterStart == start && weakSelf.filterLimit == limit) ) {
#ifdef TESTING
            NSLog(@"[%@ Wrong EPG received - discarding request.", weakSelf.statsEpgName );
#endif
            return ;
        }
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:profilingDate];
        [TVHAnalytics sendTimingWithCategory:@"Network Profiling"
                                   withValue:time
                                    withName:weakSelf.statsEpgName
                                   withLabel:nil];
#ifdef TESTING
        NSLog(@"[%@ Profiling Network]: %f", weakSelf.statsEpgName, time);
#endif
        if ( [weakSelf fetchedData:responseObject] ) {
            [weakSelf signalDidLoadEpg];
            [weakSelf getMoreEpg:start limit:limit fetchAll:fetchAll];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[EpgStore HTTPClient Error]: %@", error.localizedDescription);
        [weakSelf signalDidErrorLoadingEpgStore:error];
    }];
    
}

- (void)getMoreEpg:(NSInteger)start limit:(NSInteger)limit fetchAll:(BOOL)fetchAll {
    // get last epg
    // check date
    // if date > datenow, get more 50 (DEFAULT_REQUEST_EPG_ITEMS)
    if ( fetchAll ) {
        if ( (start+limit) < self.totalEventCount ) {
            [self retrieveEpgDataFromTVHeadend:(start+limit) limit:MAX_REQUEST_EPG_ITEMS fetchAll:true];
        }
    } else {
        TVHEpg *last = [self.epgStore lastObject];
        if ( last ) {
            NSDate *localDate = [NSDate dateWithTimeIntervalSinceNow:SECONDS_TO_FETCH_AHEAD_EPG_ITEMS];
    #ifdef TESTING
            //NSLog(@"localdate: %@ | last start date: %@ ", localDate, last.start);
    #endif
            if ( [localDate compare:last.start] == NSOrderedDescending && (start+limit) < self.totalEventCount ) {
                [self retrieveEpgDataFromTVHeadend:(start+limit) limit:DEFAULT_REQUEST_EPG_ITEMS fetchAll:false];
            }
        }
    }
}

- (void)downloadAllEpgItems {
    [self retrieveEpgDataFromTVHeadend:0 limit:300 fetchAll:true];
}

- (void)downloadEpgList {
    [self retrieveEpgDataFromTVHeadend:0 limit:DEFAULT_REQUEST_EPG_ITEMS fetchAll:false];
}

- (void)downloadMoreEpgList {
    [self retrieveEpgDataFromTVHeadend:[self.epgStore count] limit:DEFAULT_REQUEST_EPG_ITEMS fetchAll:false];
}

- (void)clearEpgData {
    self.epgStore = nil;
}

- (NSArray*)epgStoreItems{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for ( TVHEpg *epg in self.epgStore ) {
        if ( [epg progress] < 100 ) {
            [items addObject:epg];
        }
    }
    return [items copy];
}

- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)setFilterToProgramTitle:(NSString *)filterToProgramTitle {
    if( ! [filterToProgramTitle isEqualToString:_filterToProgramTitle] ) {
        _filterToProgramTitle = filterToProgramTitle;
        self.epgStore = nil;
    }
}

- (void)setFilterToChannelName:(NSString *)filterToChannelName {
    if ( ! [filterToChannelName isEqualToString:_filterToChannelName] ) {
        _filterToChannelName = filterToChannelName;
        self.epgStore = nil;
    }
}

- (void)setFilterToTagName:(NSString *)filterToTagName {
    if ( ! [filterToTagName isEqualToString:_filterToTagName] ) {
        _filterToTagName = filterToTagName;
        self.epgStore = nil;
    }
}

- (void)setFilterToContentTypeId:(NSString *)filterToContentTypeId {
    if ( ! [filterToContentTypeId isEqualToString:_filterToContentTypeId] ) {
        _filterToContentTypeId = filterToContentTypeId;
        self.epgStore = nil;
    }
}

- (void)signalWillLoadEpg {
    if ([self.delegate respondsToSelector:@selector(willLoadEpg)]) {
        [self.delegate willLoadEpg];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willLoadEpg"
                                                        object:self];
}

- (void)signalDidLoadEpg {
    if ([self.delegate respondsToSelector:@selector(didLoadEpg)]) {
        [self.delegate didLoadEpg];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadEpg"
                                                        object:self];
}

- (void)signalDidErrorLoadingEpgStore:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorLoadingEpgStore:)]) {
        [self.delegate didErrorLoadingEpgStore:error];
    }
}


@end
