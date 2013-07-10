//
//  TVHServer.m
//  TvhClient
//
//  Created by zipleen on 16/05/2013.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHServer.h"

@implementation TVHServer

- (TVHServer*)initVersion:(NSString*)version {
    self = [super init];
    if (self) {
        [self setVersion:version];
        [self.tagStore fetchTagList];
        [self.channelStore fetchChannelList];
        [self.statusStore fetchStatusSubscriptions];
        [self.adapterStore fetchAdapters];
        [self.logStore clearLog];
    }
    return self;
}

- (TVHTagStore*)tagStore {
    if( ! _tagStore ) {
        _tagStore = [[TVHTagStore alloc] initWithTvhServer:self];
    }
    return _tagStore;
}

- (TVHChannelStore*)channelStore {
    if( ! _channelStore ) {
        _channelStore = [[TVHChannelStore alloc] initWithTvhServer:self];
        [_channelStore fetchChannelList];
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

- (TVHStatusSubscriptionsStore*)statusStore {
    if( ! _statusStore ) {
        _statusStore = [[TVHStatusSubscriptionsStore alloc] initWithTvhServer:self];
    }
    return _statusStore;
}

- (TVHAdaptersStore*)adapterStore {
    if( ! _adapterStore ) {
        _adapterStore = [[TVHAdaptersStore alloc] initWithTvhServer:self];
    }
    return _adapterStore;
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

- (void)fetchServerVersion {
    
    [self.jsonClient getPath:@"extjs.html" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<title>HTS Tvheadend (.*?)</title>" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *versionRange = [regex firstMatchInString:response
                                                               options:0
                                                                 range:NSMakeRange(0, [response length])];
        if ( versionRange ) {
            NSString* versionString = [response substringWithRange:[versionRange rangeAtIndex:1]];
            versionString = [versionString stringByReplacingOccurrencesOfString:@"." withString:@""];
            self.version = [versionString substringWithRange:NSMakeRange(0, 2)];
#ifdef TESTING
            NSLog(@"[TVHServer getVersion]: %@", self.version);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadTVHVersion"
                                                                object:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[TVHServer getVersion]: %@", error.localizedDescription);
    }];
}

- (void)resetData {
    self.jsonClient = nil;
    self.tagStore = nil;
    self.channelStore = nil;
    self.dvrStore = nil;
    self.autorecStore = nil;
    self.statusStore = nil;
    self.adapterStore = nil;
    self.cometStore = nil;
}

@end
