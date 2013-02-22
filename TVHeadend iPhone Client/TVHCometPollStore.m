//
//  TVHCometPollStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/21/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHCometPollStore.h"
#import "TVHSettings.h"
#import "TVHJsonHelper.h"
#import "TVHJsonClient.h"

@interface TVHCometPollStore()
@property (nonatomic, strong) NSString *boxid;
@end

@implementation TVHCometPollStore
@synthesize boxid = _boxid;

+ (id)sharedInstance {
    static TVHCometPollStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHCometPollStore alloc] init];
    });
    
    return __sharedInstance;
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary *json = [TVHJsonHelper convertFromJsonToObject:responseData error:error];
    if( error ) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"didErrorCometPollStore"
            object:error];
        return ;
    }
    
    NSString *boxid = [json objectForKey:@"boxid"];
    self.boxid = boxid;
    
    NSArray *messages = [json objectForKey:@"messages"];
    
    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *notificationClass = [obj objectForKey:@"notificationClass"];
#if DEBUG
        NSLog(@"[Comet Poll Received notificationClass]: %@", notificationClass);
#endif
        
        if( [notificationClass isEqualToString:@"subscriptions"] ) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"subscriptionsNotificationClassReceived"
                object:obj];
        }
    }];
    
    
}

- (void)fetchCometPollStatus {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.boxid, @"boxid", @"0", @"immediate", nil];
    
    [httpClient postPath:@"/comet/poll" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"didErrorCometPollStore"
            object:error];
#if DEBUG
        NSLog(@"[CometPollStore HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
    
}


@end
