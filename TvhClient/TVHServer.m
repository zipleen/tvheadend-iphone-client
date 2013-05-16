//
//  TVHServer.m
//  TvhClient
//
//  Created by zipleen on 16/05/2013.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHServer.h"

@implementation TVHServer

- (TVHServer*)init {
    self = [super init];
    if (self) {
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetData)
                                                     name:@"resetAllObjects"
                                                   object:nil];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (TVHTagStore*)tagStore {
    if( ! _tagStore ) {
        _tagStore = [[TVHTagStore alloc] init];
    }
    return _tagStore;
}

- (TVHChannelStore*)channelStore {
    if( ! _channelStore ) {
        _channelStore = [[TVHChannelStore alloc] initWithTvhServer:self];
    }
    return _channelStore;
}

- (TVHDvrStore*)dvrStore {
    if( ! _dvrStore ) {
        _dvrStore = [[TVHDvrStore alloc] initWithTvhServer:self];
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
