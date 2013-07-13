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
#import "TVHServer.h"

@interface TVHCometPollStore() {
    bool timerStarted;
}
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSString *boxid;
@property (nonatomic) BOOL debugActive;
@end

@implementation TVHCometPollStore

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
    self.debugActive = false;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchCometPollStatus)
                                                 name:@"fetchCometPollStatus"
                                               object:nil];
    
    return self;
}

- (void)appWillResignActive:(NSNotification*)note {
    
}

- (void)appWillEnterForeground:(NSNotification*)note {
    if ( timerStarted ) {
        [self startRefreshingCometPoll];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fetchCometPollStatus" object:nil];
    self.boxid = nil;
}

- (BOOL)fetchedData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"didErrorCometPollStore"
            object:error];
        return false;
    }
    
    NSString *boxid = [json objectForKey:@"boxid"];
    self.boxid = boxid;
    
    NSArray *messages = [json objectForKey:@"messages"];
    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *notificationClass = [obj objectForKey:@"notificationClass"];
#ifdef TESTING
        //NSLog(@"[Comet Poll Received notificationClass]: %@ {%@}", notificationClass, obj);
        BOOL print = YES;
#endif
        if( [notificationClass isEqualToString:@"subscriptions"] ) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"subscriptionsNotificationClassReceived"
                object:obj];
#ifdef TESTING
            print = NO;
#endif
        }
        
        if( [notificationClass isEqualToString:@"tvAdapter"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"tvAdapterNotificationClassReceived"
             object:obj];
#ifdef TESTING
            print = NO;
#endif
        }
        
        if( [notificationClass isEqualToString:@"logmessage"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"logmessageNotificationClassReceived"
             object:obj];
#ifdef TESTING
            print = NO;
#endif
        }
        
        if( [notificationClass isEqualToString:@"dvbMux"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"dvbMuxNotificationClassReceived"
             object:obj];
#ifdef TESTING
            print = NO;
#endif
        }
        
        if( [notificationClass isEqualToString:@"dvrdb"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"dvrdbNotificationClassReceived"
             object:obj];
#ifdef TESTING
            print = NO;
#endif
        }
        
        if( [notificationClass isEqualToString:@"autorec"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"autorecNotificationClassReceived"
             object:obj];
#ifdef TESTING
            print = NO;
#endif
        }
        
        if( [notificationClass isEqualToString:@"channels"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"channelsNotificationClassReceived"
             object:obj];
#ifdef TESTING
            print = NO;
#endif
        }
        
        if( [notificationClass isEqualToString:@"channeltags"] ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"channeltagsNotificationClassReceived"
             object:obj];
#ifdef TESTING
            print = NO;
#endif
        }
        
#ifdef TESTING
        if(print) {
            NSLog(@"[CometPollStore log]: %@", obj);
        }
#endif
    }];
    
    return true;
}

- (void)toggleDebug {
    
    self.debugActive = !self.debugActive;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.boxid, @"boxid", @"0", @"immediate", nil];
    
    [self.jsonClient postPath:@"comet/debug" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchCometPollStatus];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

- (void)fetchCometPollStatus {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.boxid, @"boxid", @"0", @"immediate", nil];
    //self.profilingDate = [NSDate date];
    [self.jsonClient postPath:@"comet/poll" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.profilingDate];
#ifdef TESTING
        //NSLog(@"[CometPoll Profiling Network]: %f", time);
#endif
        if ( [self fetchedData:responseObject] ) {
            if( timerStarted ) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchCometPollStatus"
                                                                    object:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if( timerStarted ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchCometPollStatus"
                                                                object:nil];
        }
#ifdef TESTING
        NSLog(@"[CometPollStore HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
    
}

- (void)startRefreshingCometPoll {
#ifdef TESTING
    NSLog(@"[Comet Poll Timer]: Starting comet poll refresh");
#endif
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fetchCometPollStatus) userInfo:nil repeats:YES];
    timerStarted = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchCometPollStatus"
                                                        object:nil];
}

- (void)stopRefreshingCometPoll {
#ifdef TESTING
    NSLog(@"[Comet Poll Timer]: Stopped comet poll refresh");
#endif
    //[self.timer invalidate];
    timerStarted = NO;
}

- (BOOL)isTimerStarted {
    return timerStarted;
}

- (BOOL)isDebugActive {
    return self.debugActive;
}
@end
