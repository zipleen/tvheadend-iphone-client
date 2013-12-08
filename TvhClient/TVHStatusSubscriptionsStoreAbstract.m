//
//  TVHStatusSubscriptionsStore.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/18/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHStatusSubscriptionsStoreAbstract.h"
#import "TVHServer.h"

@interface TVHStatusSubscriptionsStoreAbstract()
@property (nonatomic, weak) TVHApiClient *apiClient;
@property (nonatomic, strong) NSArray *subscriptions;
@end

@implementation TVHStatusSubscriptionsStoreAbstract

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.apiClient = [self.tvhServer apiClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSubscriptionNotification:)
                                                 name:@"subscriptionsNotificationClassReceived"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchStatusSubscriptions)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.subscriptions = nil;
}

- (void)receiveSubscriptionNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"subscriptionsNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        if ( [[message objectForKey:@"reload"] intValue] == 1 ) {
            [self fetchStatusSubscriptions];
        }
        
        [self.subscriptions enumerateObjectsUsingBlock:^(TVHStatusSubscription* obj, NSUInteger idx, BOOL *stop) {
            if ( obj.id == [[message objectForKey:@"id"] intValue] ) {
                [obj updateValuesFromDictionary:message];
            }
        }];
        
        [self signalDidLoadStatusSubscriptions];
    }
}

- (BOOL)fetchedData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        [self signalDidErrorStatusSubscriptionsStore:error];
        return false;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *subscriptions = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHStatusSubscription *subscription = [[TVHStatusSubscription alloc] init];
        [subscription updateValuesFromDictionary:obj];
        
        [subscriptions addObject:subscription];
    }];
    
    self.subscriptions = [subscriptions copy];
    
#ifdef TESTING
    NSLog(@"[Loaded Subscription]: %d", [self.subscriptions count]);
#endif
    [TVHDebugLytics setIntValue:[self.subscriptions count] forKey:@"subscriptions"];
    return true;
}

#pragma mark Api Client delegates

- (NSString*)apiMethod {
    return @"GET";
}

- (NSString*)apiPath {
    return @"subscriptions";
}

- (NSDictionary*)apiParameters {
    return nil;
}

- (void)fetchStatusSubscriptions {
    TVHStatusSubscriptionsStoreAbstract __weak *weakSelf = self;
    
    [self signalWillLoadStatusSubscriptions];
    [self.apiClient doApiCall:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ( [weakSelf fetchedData:responseObject] ) {
            [weakSelf signalDidLoadStatusSubscriptions];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf signalDidErrorStatusSubscriptionsStore:error];
        NSLog(@"[Subscription HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (TVHStatusSubscription *) objectAtIndex:(int) row {
    if ( row < [self.subscriptions count] ) {
        return [self.subscriptions objectAtIndex:row];
    }
    return nil;
}

- (int)count {
    return [self.subscriptions count];
}

- (void)setDelegate:(id <TVHStatusSubscriptionsDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

#pragma mark Signal delegates

- (void)signalDidLoadStatusSubscriptions {
    if ([self.delegate respondsToSelector:@selector(didLoadStatusSubscriptions)]) {
        [self.delegate didLoadStatusSubscriptions];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadStatusSubscriptions"
                                                        object:self];
}

- (void)signalWillLoadStatusSubscriptions {
    if ([self.delegate respondsToSelector:@selector(willLoadStatusSubscriptions)]) {
        [self.delegate willLoadStatusSubscriptions];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willLoadStatusSubscriptions"
                                                        object:self];
}

- (void)signalDidErrorStatusSubscriptionsStore:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorLoadingTagStore:)]) {
        [self.delegate didErrorStatusSubscriptionsStore:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didErrorStatusSubscriptionsStore"
                                                        object:error];
}

@end
