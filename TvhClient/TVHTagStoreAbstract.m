//
//  TVHTagStore.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHTagStoreAbstract.h"
#import "TVHSettings.h"
#import "TVHServer.h"

@interface TVHTagStoreAbstract()
@property (nonatomic, weak) TVHApiClient *apiClient;
@property (nonatomic, strong) NSArray *tags;
@end

@implementation TVHTagStoreAbstract

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.apiClient = [self.tvhServer apiClient];
    
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
    self.apiClient = nil;
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
    
    [entries enumerateObjectsUsingBlock:^(id entry, NSUInteger idx, BOOL *stop) {
        NSInteger enabled = [[entry objectForKey:@"enabled"] intValue];
        if( enabled ) {
            TVHTag *tag = [[TVHTag alloc] initWithTvhServer:self.tvhServer];
            [tag updateValuesFromDictionary:entry];
            [tags addObject:tag];
        }
    }];
     
    NSMutableArray *orderedTags = [[tags sortedArrayUsingSelector:@selector(compareByName:)] mutableCopy];
    
    // All channels
    TVHTag *tag = [[TVHTag alloc] initWithAllChannels:self.tvhServer];
    [orderedTags insertObject:tag atIndex:0];
    
    self.tags = [orderedTags copy];
#ifdef TESTING
    NSLog(@"[Loaded Tags]: %d", [self.tags count]);
#endif
    [TVHDebugLytics setIntValue:[self.tags count] forKey:@"tags"];
    return true;
}

#pragma mark Api Client delegates

- (NSString*)apiMethod {
    return @"POST";
}

- (NSString*)apiPath {
    return @"tablemgr";
}

- (NSDictionary*)apiParameters {
    return [NSDictionary dictionaryWithObjectsAndKeys:@"get", @"op", @"channeltags", @"table", nil];
}

- (void)fetchTagList {
    [self signalWillLoadTags];
    TVHTagStoreAbstract __weak *weakSelf = self;
    __block NSDate *profilingDate = [NSDate date];
    
    [self.apiClient doApiCall:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:profilingDate];
        [TVHAnalytics sendTimingWithCategory:@"Network Profiling"
                                   withValue:time
                                    withName:@"TagStore"
                                   withLabel:nil];
#ifdef TESTING
        NSLog(@"[TagStore Profiling Network]: %f", time);
#endif
        if ( [weakSelf fetchedData:responseObject] ) {
            [weakSelf signalDidLoadTags];
        }
        
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf signalDidErrorLoadingTagStore:error];
        NSLog(@"[TagStore HTTPClient Error]: %@", error.description);
    }];
}

- (void)setDelegate:(id <TVHTagStoreDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

#pragma mark singals

- (void)signalWillLoadTags {
    if ([self.delegate respondsToSelector:@selector(willLoadTags)]) {
        [self.delegate didLoadTags];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willLoadTags"
                                                        object:self];
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
