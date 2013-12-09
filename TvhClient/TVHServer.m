//
//  TVHServer.m
//  TvhClient
//
//  Created by Luis Fernandes on 16/05/2013.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHServer.h"

@interface TVHServer() {
    BOOL inProcessing;
}
@property (nonatomic, strong) TVHJsonClient *jsonClient;
@property (nonatomic, strong) TVHApiClient *apiClient;
@property (nonatomic, strong) id <TVHTagStore> tagStore;
@property (nonatomic, strong) id <TVHChannelStore> channelStore;
@property (nonatomic, strong) id <TVHDvrStore> dvrStore;
@property (nonatomic, strong) TVHAutoRecStore *autorecStore;
@property (nonatomic, strong) id <TVHStatusSubscriptionsStore> statusStore;
@property (nonatomic, strong) id <TVHAdaptersStore> adapterStore;
@property (nonatomic, strong) id <TVHMuxStore> muxStore;
@property (nonatomic, strong) id <TVHServiceStore> serviceStore;
@property (nonatomic, strong) TVHLogStore *logStore;
@property (nonatomic, strong) TVHCometPollStore *cometStore;
@property (nonatomic, strong) TVHConfigNameStore *configNameStore;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *realVersion;
@property (nonatomic, strong) NSArray *capabilities;
@property (nonatomic, strong) NSDictionary *configSettings;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation TVHServer 

#pragma mark NSNotification

- (void)appWillResignActive:(NSNotification*)note {
    [self.timer invalidate];
}

- (void)appWillEnterForeground:(NSNotification*)note {
    [self processTimerEvents];
    [self startTimer];
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(processTimerEvents) userInfo:nil repeats:YES];
}

- (void)processTimerEvents {
    if ( ! inProcessing ) {
        inProcessing = YES;
        [self.channelStore updateChannelsProgress];
        inProcessing = NO;
    }
}

#pragma mark init

- (TVHServer*)initVersion:(NSString*)version {
    self = [super init];
    if (self) {
        inProcessing = NO;
        [self setVersion:version];
        [self.tagStore fetchTagList];
        [self.channelStore fetchChannelList];
        [self.statusStore fetchStatusSubscriptions];
        [self.adapterStore fetchAdapters];
        [self.muxStore fetchMuxes];
        [self.serviceStore fetchServices];
        [self logStore];
        [self fetchServerVersion];
        if ( [self.version isEqualToString:@"34"] ) {
            [self fetchCapabilities];
        }
        [self.configNameStore fetchConfigNames];
        [self fetchConfigSettings];
        [self cometStore];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [self startTimer];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetData {
    [self.timer invalidate];
    self.timer = nil;
    
    self.jsonClient = nil;
    self.tagStore = nil;
    self.channelStore = nil;
    self.dvrStore = nil;
    self.autorecStore = nil;
    self.statusStore = nil;
    self.adapterStore = nil;
    self.cometStore = nil;
    self.configNameStore = nil;
    self.capabilities = nil;
    self.version = nil;
    self.realVersion = nil;
    self.configSettings = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Main Objects

- (id <TVHTagStore>)tagStore {
    if( ! _tagStore ) {
        Class myClass = NSClassFromString([@"TVHTagStore" stringByAppendingString:self.version]);
        _tagStore = [[myClass alloc] initWithTvhServer:self];
    }
    return _tagStore;
}

- (id <TVHChannelStore>)channelStore {
    if( ! _channelStore ) {
        Class myClass = NSClassFromString([@"TVHChannelStore" stringByAppendingString:self.version]);
        _channelStore = [[myClass alloc] initWithTvhServer:self];
    }
    return _channelStore;
}

- (id <TVHDvrStore>)dvrStore {
    if( ! _dvrStore ) {
        Class myClass = NSClassFromString([@"TVHDvrStore" stringByAppendingString:self.version]);
        _dvrStore = [[myClass alloc] initWithTvhServer:self];
    }
    return _dvrStore;
}

- (TVHAutoRecStore*)autorecStore {
    if( ! _autorecStore ) {
        _autorecStore = [[TVHAutoRecStore alloc] initWithTvhServer:self];
    }
    return _autorecStore;
}

- (id <TVHStatusSubscriptionsStore>)statusStore {
    if( ! _statusStore ) {
        Class myClass = NSClassFromString([@"TVHStatusSubscriptionsStore" stringByAppendingString:self.version]);
        _statusStore = [[myClass alloc] initWithTvhServer:self];
    }
    return _statusStore;
}

- (id <TVHAdaptersStore>)adapterStore {
    if( ! _adapterStore ) {
        Class myClass = NSClassFromString([@"TVHAdaptersStore" stringByAppendingString:self.version]);
        _adapterStore = [[myClass alloc] initWithTvhServer:self];
    }
    return _adapterStore;
}

- (id <TVHMuxStore>)muxStore {
    if( ! _muxStore ) {
        Class myClass = NSClassFromString([@"TVHMuxStore" stringByAppendingString:self.version]);
        _muxStore = [[myClass alloc] initWithTvhServer:self];
    }
    return _muxStore;
}

- (id <TVHServiceStore>)serviceStore {
    if( ! _serviceStore ) {
        Class myClass = NSClassFromString([@"TVHServiceStore" stringByAppendingString:self.version]);
        _serviceStore = [[myClass alloc] initWithTvhServer:self];
    }
    return _serviceStore;
}

- (TVHLogStore*)logStore {
    if( ! _logStore ) {
        _logStore = [[TVHLogStore alloc] init];
    }
    return _logStore;
}

- (TVHCometPollStore*)cometStore {
    if( ! _cometStore ) {
        _cometStore = [[TVHCometPollStore alloc] initWithTvhServer:self];
        if ( [[TVHSettings sharedInstance] autoStartPolling] ) {
            [_cometStore startRefreshingCometPoll];
        }
    }
    return _cometStore;
}

- (TVHJsonClient*)jsonClient {
    if( ! _jsonClient ) {
        _jsonClient = [[TVHJsonClient alloc] init];
    }
    return _jsonClient;
}

- (TVHApiClient*)apiClient {
    if( ! _apiClient ) {
        _apiClient = [[TVHApiClient alloc] initWithClient:self.jsonClient];
    }
    return _apiClient;
}

- (TVHConfigNameStore*)configNameStore {
    if( ! _configNameStore ) {
        _configNameStore = [[TVHConfigNameStore alloc] initWithTvhServer:self];
    }
    return _configNameStore;
}

- (id <TVHEpgStore>)createEpgStoreWithName:(NSString*)statsName {
    Class myClass = NSClassFromString([@"TVHEpgStore" stringByAppendingString:self.version]);
    id <TVHEpgStore> epgStore = [[myClass alloc] initWithStatsEpgName:statsName withTvhServer:self];
    return epgStore;
}

- (NSString*)version {
    if ( _version ) {
        int ver = [_version intValue];
        if ( ver >= 30 && ver <= 32 ) {
            return @"32";
        }
        if ( ver >= 33 && ver <= 35 ) {
            return @"34";
        }
        if ( ver >= 36 ) {
            return @"40";
        }
    }
    return @"34";
}

#pragma mark fetch version

- (void)handleFetchedServerVersion:(NSString*)response {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<title>HTS Tvheadend (.*?)</title>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *versionRange = [regex firstMatchInString:response
                                                           options:0
                                                             range:NSMakeRange(0, [response length])];
    if ( versionRange ) {
        NSString *versionString = [response substringWithRange:[versionRange rangeAtIndex:1]];
        _realVersion = versionString;
        [TVHDebugLytics setObjectValue:_realVersion forKey:@"realVersion"];
        versionString = [versionString stringByReplacingOccurrencesOfString:@"." withString:@""];
        if ([versionString length] > 1) {
            self.version = [versionString substringWithRange:NSMakeRange(0, 2)];
#ifdef TESTING
            NSLog(@"[TVHServer getVersion]: %@", self.version);
#endif
            [TVHDebugLytics setObjectValue:self.version forKey:@"version"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadTVHVersion"
                                                                object:self];
        }
    }
}

- (void)fetchServerVersion {
    [self.jsonClient getPath:@"extjs.html" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self handleFetchedServerVersion:response];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[TVHServer getVersion]: %@", error.localizedDescription);
    }];
}

#pragma mark fetch capabilities

- (void)fetchCapabilities {
    [self.jsonClient getPath:@"capabilities" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSArray *json = [TVHJsonClient convertFromJsonToArray:responseObject error:&error];
        if( error ) {
            NSLog(@"[TVHServer fetchCapabilities]: error %@", error.description);
            return ;
        }
        _capabilities = json;
#ifdef TESTING
        NSLog(@"[TVHServer capabilities]: %@", _capabilities);
#endif
        [TVHDebugLytics setObjectValue:_capabilities forKey:@"server.capabilities"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadTVHCapabilities"
                                                            object:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[TVHServer capabilities]: %@", error.localizedDescription);
    }];

}

- (void)fetchConfigSettings {
    [self.jsonClient getPath:@"config" parameters:@{@"op":@"loadSettings"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseObject error:&error];
        
        if( error ) {
            NSLog(@"[TVHServer fetchConfigSettings]: error %@", error.description);
            return ;
        }
        
        NSArray *entries = [json objectForKey:@"config"];
        NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
        
        [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [config setValue:obj forKey:key];
            }];
        }];
        
        self.configSettings = [config copy];
#ifdef TESTING
        NSLog(@"[TVHServer configSettings]: %@", self.configSettings);
#endif
        [TVHDebugLytics setObjectValue:self.configSettings forKey:@"server.configSettings"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadTVHConfigSettings"
                                                            object:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[TVHServer capabilities]: %@", error.localizedDescription);
    }];
    
}

- (BOOL)isTranscodingCapable {
    if ( self.capabilities ) {
        NSInteger idx = [self.capabilities indexOfObject:@"transcoding"];
        if ( idx != NSNotFound ) {
            // check config settings now
            NSNumber *transcodingEnabled = [self.configSettings objectForKey:@"transcoding_enabled"];
            if ( [transcodingEnabled integerValue] == 1 ) {
                return true;
            }
        }
    }
    return false;
}

#pragma mark TVH Server Details

- (NSString*)htspUrl {
    TVHSettings *settings = [TVHSettings sharedInstance];
    NSString *userAndPass = @"";
    if ( ![[settings username] isEqualToString:@""] ) {
        userAndPass = [NSString stringWithFormat:@"%@:%@@", [settings username], [settings password]];
    }
    return [NSString stringWithFormat:@"htsp://%@%@:%@", userAndPass, [settings ipForCurrentServer], [settings htspPortForCurrentServer]];
}

- (NSString*)baseUrl {
    TVHSettings *settings = [TVHSettings sharedInstance];
    return [settings fullBaseURL];
}



@end
