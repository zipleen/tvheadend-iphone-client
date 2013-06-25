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
        _dvrStore = [[TVHDvrStore34 alloc] initWithTvhServer:self];
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
