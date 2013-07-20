//
//  TVHTagStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHTagStore.h"
#import "TVHSettings.h"
#import "TVHServer.h"

@interface TVHTagStore()
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSDate *profilingDate;
@end


@implementation TVHTagStore

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchTagList)
                                                 name:@"channeltagsNotificationClassReceived"
                                               object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tags = nil;
    self.tvhServer = nil;
    self.jsonClient = nil;
    self.profilingDate = nil;
}

- (bool)fetchedData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        [self signalDidErrorLoadingTagStore:error];
        return false;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    
    for (id entry in entries) {
        NSInteger enabled = [[entry objectForKey:@"enabled"] intValue];
        if( enabled ) {
            TVHTag *tag = [[TVHTag alloc] init];
            [tag updateValuesFromDictionary:entry];
            [tags addObject:tag];
        }
    }
     
    NSMutableArray *orderedTags = [[tags sortedArrayUsingSelector:@selector(compareByName:)] mutableCopy];
    
    // All channels
    TVHTag *t = [[TVHTag alloc] initWithAllChannels];
    [orderedTags insertObject:t atIndex:0];
    
    self.tags = [orderedTags copy];
#ifdef TESTING
    NSLog(@"[Loaded Tags]: %d", [self.tags count]);
#endif
    return true;
}

- (void)fetchTagList {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"get", @"op", @"channeltags", @"table", nil];
    self.profilingDate = [NSDate date];
    [self.jsonClient postPath:@"tablemgr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.profilingDate];
#ifdef TVH_GOOGLEANALYTICS_KEY
        [[GAI sharedInstance].defaultTracker sendTimingWithCategory:@"Network Profiling"
                                                          withValue:time
                                                           withName:@"TagStore"
                                                          withLabel:nil];
#endif
#ifdef TESTING
        NSLog(@"[TagStore Profiling Network]: %f", time);
#endif
        if ( [self fetchedData:responseObject] ) {
            [self signalDidLoadTags];
        }
        
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self signalDidErrorLoadingTagStore:error];
        NSLog(@"[TagList HTTPClient Error]: %@", error.description);
    }];
}

- (void)setDelegate:(id <TVHTagStoreDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)signalDidLoadTags {
    if ([self.delegate respondsToSelector:@selector(didLoadTags)]) {
        [self.delegate didLoadTags];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadTags"
                                                        object:self];
}

- (void)signalDidErrorLoadingTagStore:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorLoadingTagStore:)]) {
        [self.delegate didErrorLoadingTagStore:error];
    }
}

@end
