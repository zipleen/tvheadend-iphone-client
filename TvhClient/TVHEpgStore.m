//
//  TVHEpgStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpgStore.h"
#import "TVHEpg.h"
#import "TVHJsonClient.h"

@interface TVHEpgStore()
@property (nonatomic, strong) NSArray *epgStore;
@property (nonatomic, weak) id <TVHEpgStoreDelegate> delegate;
@property (nonatomic) NSInteger lastEventCount;

@end

@implementation TVHEpgStore

+ (id)sharedInstance {
    static TVHEpgStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHEpgStore alloc] init];
    });
    
    return __sharedInstance;
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
    
    self.lastEventCount = [[json objectForKey:@"totalCount"] intValue];
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *epgStore = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHEpg *epg = [[TVHEpg alloc] init];
        [epg updateValuesFromDictionary:obj];
        [epgStore addObject:epg];
    }];
    
    if ( [self.epgStore count] > 0) {
        self.epgStore = [self.epgStore arrayByAddingObjectsFromArray:[epgStore copy]];
    } else {
        self.epgStore = [epgStore copy];
    }
#ifdef TESTING
    NSLog(@"[EpgStore: Loaded EPG programs (%@)]: %d", self.filterToChannelName,[self.epgStore count]);
#endif
}

- (NSDictionary*) getPostParametersStartingFrom:(NSInteger)start limit:(NSInteger)limit {
    
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

- (void)retrieveEpgDataFromTVHeadend:(NSInteger)start limit:(NSInteger)limit {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    NSDictionary *params = [self getPostParametersStartingFrom:start limit:limit];
    
    [httpClient postPath:@"/epg" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        [self.delegate didLoadEpg:self];
        
        [self getMoreEpg:start limit:limit];
        
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef TESTING
        NSLog(@"[EpgStore HTTPClient Error]: %@", error.localizedDescription);
#endif
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingEpgStore:)]) {
            [self.delegate didErrorLoadingEpgStore:error];
        }
    }];
    
}

- (void)getMoreEpg:(NSInteger)start limit:(NSInteger)limit {
    // get last epg
    // check date
    // if date > datenow, get more 50
    
    TVHEpg *last = [self.epgStore lastObject];
    if ( last ) {
        NSDate *localDate = [NSDate date];
#ifdef TESTING
        NSLog(@"localdate: %@ | last start date: %@", localDate, last.start);
#endif
        if ( localDate > last.start && self.lastEventCount<(start+limit) ) {
            [self retrieveEpgDataFromTVHeadend:(start+limit) limit:50];
        }
    }
}

- (void)downloadEpgList {
    [self retrieveEpgDataFromTVHeadend:0 limit:50];
}

- (NSArray*)getEpgList{
    return self.epgStore;
}

- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

@end
