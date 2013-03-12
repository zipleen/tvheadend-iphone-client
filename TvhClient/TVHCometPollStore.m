//
//  TVHCometPollStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/21/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHCometPollStore.h"
#import "TVHSettings.h"
#import "TVHJsonClient.h"

@interface TVHCometPollStore() {
    bool timerStarted;
}
@property (nonatomic, strong) NSString *boxid;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) BOOL debugActive;
@end

@implementation TVHCometPollStore

+ (id)sharedInstance {
    static TVHCometPollStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHCometPollStore alloc] init];
    });
    
    return __sharedInstance;
}

- (id) init {
    self = [super init];
    if (!self) return nil;
    
    self.debugActive = false;
    return self;
}


- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:error];
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
#ifdef TESTING
        //NSLog(@"[Comet Poll Received notificationClass]: %@", notificationClass);
#endif
        BOOL print = YES;
        if( [notificationClass isEqualToString:@"subscriptions"] ) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"subscriptionsNotificationClassReceived"
                object:obj];
            print = NO;
        }
        
        if( [notificationClass isEqualToString:@"tvAdapter"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"tvAdapterNotificationClassReceived"
             object:obj];
            print = NO;
        }
        
        if( [notificationClass isEqualToString:@"logmessage"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"logmessageNotificationClassReceived"
             object:obj];
            print = NO;
        }
        
        if( [notificationClass isEqualToString:@"dvbMux"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"dvbMuxNotificationClassReceived"
             object:obj];
            print = NO;
        }

        if(print)
            NSLog(@"[CometPollStore log]: %@", obj);
    }];
    
    
}

- (void)toggleDebug {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    self.debugActive = !self.debugActive;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.boxid, @"boxid", @"0", @"immediate", nil];
    
    [httpClient postPath:@"/comet/debug" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
#ifdef TESTING
        NSLog(@"[CometPollStore HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
    
}

- (void)startRefreshingCometPoll {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[TVHCometPollStore sharedInstance] selector:@selector(fetchCometPollStatus) userInfo:nil repeats:YES];
    timerStarted = YES;
}

- (void)stopRefreshingCometPoll {
    [self.timer invalidate];
    timerStarted = NO;
}

- (BOOL)isTimerStarted {
    return timerStarted;
}

- (BOOL)isDebugActive {
    return self.debugActive;
}
@end
