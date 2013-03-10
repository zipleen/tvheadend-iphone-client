//
//  TVHAdaptersStore.m
//  TvhClient
//
//  Created by zipleen on 06/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHAdaptersStore.h"
#import "TVHJsonClient.h"

@interface TVHAdaptersStore()
@property (nonatomic, strong) NSArray *adapters;
@property (nonatomic, weak) id <TVHAdaptersDelegate> delegate;
@end

@implementation TVHAdaptersStore
- (id) init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSubscriptionNotification:)
                                                 name:@"tvAdapterNotificationClassReceived"
                                               object:nil];
    
    return self;
}

- (void) dealloc {
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) receiveSubscriptionNotification:(NSNotification *) notification {
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
    
#if DEBUG
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
#if DEBUG
        NSLog(@"[Adapter Store HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
    
}

- (TVHAdapter *) objectAtIndex:(int) row {
    return [self.adapters objectAtIndex:row];
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
