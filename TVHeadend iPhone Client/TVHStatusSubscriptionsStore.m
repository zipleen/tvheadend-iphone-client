//
//  TVHStatusSubscriptionsStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHStatusSubscriptionsStore.h"
#import "TVHJsonHelper.h"
#import "TVHSettings.h"

@interface TVHStatusSubscriptionsStore()
@property (nonatomic, strong) NSArray *subscriptions;
@property (nonatomic, weak) id <TVHStatusSubscriptionsDelegate> delegate;
@end

@implementation TVHStatusSubscriptionsStore
@synthesize subscriptions = _subscriptions;

+ (id)sharedInstance {
    static TVHStatusSubscriptionsStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHStatusSubscriptionsStore alloc] init];
    });
    
    return __sharedInstance;
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary *json = [TVHJsonHelper convertFromJsonToObject:responseData error:error];
    if( error ) {
        if ([self.delegate respondsToSelector:@selector(didErrorStatusSubscriptionsStore:)]) {
            [self.delegate didErrorStatusSubscriptionsStore:error];
        }
        return ;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *subscriptions = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHStatusSubscription *subscription = [[TVHStatusSubscription alloc] init];
        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [subscription setValue:obj forKey:key];
        }];
        
        [subscriptions addObject:subscription];
    }];
    
    self.subscriptions = [subscriptions copy];
    
#if DEBUG
    NSLog(@"[Loaded Subscription]: %d", [self.subscriptions count]);
#endif
}

- (void)fetchStatusSubscriptions {
    TVHSettings *settings = [TVHSettings sharedInstance];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[settings baseURL] ];
    
    [httpClient getPath:@"/subscriptions" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        [self.delegate didLoadStatusSubscriptions];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingTagStore:)]) {
            [self.delegate didErrorStatusSubscriptionsStore:error];
        }
#if DEBUG
        NSLog(@"[TagList HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
    
}

- (TVHStatusSubscription *) objectAtIndex:(int) row {
    return [self.subscriptions objectAtIndex:row];
}

- (int) count {
    return [self.subscriptions count];
}


- (void)setDelegate:(id <TVHStatusSubscriptionsDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

@end
