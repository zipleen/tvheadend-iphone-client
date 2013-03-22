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
#import "TVHJsonClient.h"

@interface TVHAdaptersStore()
@property (nonatomic, strong) NSArray *adapters;
@property (nonatomic, weak) id <TVHAdaptersDelegate> delegate;
@end

@implementation TVHAdaptersStore
- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSubscriptionNotification:)
                                                 name:@"tvAdapterNotificationClassReceived"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetAdapterStore)
                                                 name:@"resetAllObjects"
                                               object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveSubscriptionNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tvAdapterNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        [self.adapters enumerateObjectsUsingBlock:^(TVHAdapter* obj, NSUInteger idx, BOOL *stop) {
            
            if ( [obj.identifier isEqualToString:[message objectForKey:@"identifier"]] ) {
                [obj updateValuesFromDictionary:message];
            }
        }];
        [self.delegate didLoadAdapters];
    }
}

- (void)resetAdapterStore {
    self.adapters = nil;
}

+ (id)sharedInstance {
    static TVHAdaptersStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHAdaptersStore alloc] init];
    });
    
    return __sharedInstance;
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
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    [httpClient getPath:@"/tv/adapter" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        [self.delegate didLoadAdapters];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didErrorAdaptersStore:)]) {
            [self.delegate didErrorAdaptersStore:error];
        }
#ifdef TESTING
        NSLog(@"[Adapter Store HTTPClient Error]: %@", error.localizedDescription);
#endif
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
