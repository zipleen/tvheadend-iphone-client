//
//  TVHEpgList.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpgStore.h"
#import "TVHEpg.h"
#import "TVHSettings.h"
#import "TVHJsonHelper.h"

@interface TVHEpgStore()
@property (nonatomic, strong) NSArray *epgList;
@property (nonatomic, weak) id <TVHEpgStoreDelegate> delegate;
@property (nonatomic) NSInteger lastEventCount;

@end

@implementation TVHEpgStore
@synthesize epgList = _epgList;
@synthesize lastEventCount = _lastEventCount;
@synthesize filterToChannelName = _filterToChannelName;

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
    NSDictionary *json = [TVHJsonHelper convertFromJsonToObject:responseData error:error];
    if( error ) {
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingEpgStore:)]) {
            [self.delegate didErrorLoadingEpgStore:error];
        }
        return ;
    }
    
    self.lastEventCount = [[json objectForKey:@"totalCount"] intValue];
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *epgList = [[NSMutableArray alloc] init];
    
    NSEnumerator *e = [entries objectEnumerator];
    id channel;
    //for (NSEnumerator *channel in entries) {
    while (channel = [e nextObject]) {
        //NSLog(@"json : %@", channel);
        TVHEpg *e = [[TVHEpg alloc] init];
        
        NSInteger channelId = [[channel objectForKey:@"channelid"] intValue];
        NSString *title = [channel objectForKey:@"title"];
        NSString *description = [channel objectForKey:@"description"];
        NSInteger start = [[channel objectForKey:@"start"] intValue];
        NSInteger end = [[channel objectForKey:@"end"] intValue];
        NSInteger duration = [[channel objectForKey:@"duration"] intValue];
        
        [e setChannelId:channelId];
        [e setTitle:title];
        [e setDescription:description];
        [e setDuration:duration];
        [e setStartFromInteger:start];
        [e setEndFromInteger:end];
                
        [epgList addObject:e];
    }
    if ( [self.epgList count] > 0) {
        self.epgList = [self.epgList arrayByAddingObjectsFromArray:[epgList copy]];
    } else {
        self.epgList = [epgList copy];
    }
#if DEBUG
    NSLog(@"[Loaded EPG programs]: %d", [self.epgList count]);
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
    
    return [params copy];
}

- (void)retrieveEpgDataFromTVHeadend:(NSInteger)start limit:(NSInteger)limit {
    TVHSettings *settings = [TVHSettings sharedInstance];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[settings baseURL] ];
    
    NSDictionary *params = [self getPostParametersStartingFrom:start limit:limit];
    
    [httpClient postPath:@"/epg" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        [self.delegate didLoadEpg:self];
        
        [self getMoreEpg:start limit:limit];
        
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#if DEBUG
        NSLog(@"[EpgList HTTPClient Error]: %@", error.localizedDescription);
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
    
    TVHEpg *last = [self.epgList lastObject];
    if ( last ) {
        NSDate *localDate = [NSDate date];
#if DEBUG
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
    return self.epgList;
}

- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

@end
