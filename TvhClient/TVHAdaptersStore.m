//
//  TVHAdaptersStore.m
//  TvhClient
//
//  Created by zipleen on 06/03/13.
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

#import "TVHAdaptersStore.h"
#import "TVHServer.h"

@interface TVHAdaptersStore()
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSArray *adapters;
@property (nonatomic, weak) id <TVHAdaptersDelegate> delegate;
@end

@implementation TVHAdaptersStore

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSubscriptionNotification:)
                                                 name:@"tvAdapterNotificationClassReceived"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchAdapters)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.adapters = nil;
}

- (void)receiveSubscriptionNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tvAdapterNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        [self.adapters enumerateObjectsUsingBlock:^(TVHAdapter* obj, NSUInteger idx, BOOL *stop) {
            
            if ( [obj.identifier isEqualToString:[message objectForKey:@"identifier"]] ) {
                [obj updateValuesFromDictionary:message];
            }
        }];
        if ([self.delegate respondsToSelector:@selector(didLoadAdapters)]) {
            [self.delegate didLoadAdapters];
        }
    }
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:error];
    if( error ) {
        if ([self.delegate respondsToSelector:@selector(didErrorStatusSubscriptionsStore:)]) {
            [self.delegate didErrorAdaptersStore:error];
        }
        return ;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *adapters = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHAdapter *adapter = [[TVHAdapter alloc] init];
        [adapter updateValuesFromDictionary:obj];
        
        [adapters addObject:adapter];
    }];
    
    self.adapters = [adapters copy];
    
#ifdef TESTING
    NSLog(@"[Loaded Adapters]: %d", [self.adapters count]);
#endif
}

- (void)fetchAdapters {
    
    [self.jsonClient getPath:@"/tv/adapter" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        if ([self.delegate respondsToSelector:@selector(didLoadAdapters)]) {
            [self.delegate didLoadAdapters];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didErrorAdaptersStore:)]) {
            [self.delegate didErrorAdaptersStore:error];
        }
        NSLog(@"[Adapter Store HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}

- (TVHAdapter *) objectAtIndex:(int) row {
    if ( row < [self.adapters count] ) {
        return [self.adapters objectAtIndex:row];
    }
    return nil;
}

- (int) count {
    return [self.adapters count];
}


- (void)setDelegate:(id <TVHAdaptersDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}
@end
