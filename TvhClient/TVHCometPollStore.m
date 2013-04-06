//
//  TVHCometPollStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/21/13.
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
        if ( [[TVHSettings sharedInstance] autoStartPolling] ) {
            [__sharedInstance startRefreshingCometPoll];
        }
    });
    
    return __sharedInstance;
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    self.debugActive = false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    return self;
}

-(void)appWillResignActive:(NSNotification*)note {
    if ( timerStarted ) {
        [self.timer invalidate];
    }
}
-(void)appWillEnterForeground:(NSNotification*)note {
    if ( timerStarted ) {
        [self startRefreshingCometPoll];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    self.boxid = nil;
    self.timer = nil;
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
        //NSLog(@"[Comet Poll Received notificationClass]: %@ {%@}", notificationClass, obj);
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
        
        if( [notificationClass isEqualToString:@"dvrdb"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"dvrdbNotificationClassReceived"
             object:obj];
            print = NO;
        }
        
        if( [notificationClass isEqualToString:@"autorec"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"autorecNotificationClassReceived"
             object:obj];
            print = NO;
        }
        
        if(print) {
            NSLog(@"[CometPollStore log]: %@", obj);
        }
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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(fetchCometPollStatus) userInfo:nil repeats:YES];
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
