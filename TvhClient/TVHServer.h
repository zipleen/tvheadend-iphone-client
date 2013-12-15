//
//  TVHServer.h
//  TvhClient
//
//  Created by Luis Fernandes on 16/05/2013.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHServerSettings.h"
#import "TVHTagStore.h"
#import "TVHChannelStore.h"
#import "TVHEpgStore.h"
#import "TVHDvrStore.h"
#import "TVHAutoRecStore.h"
#import "TVHStatusSubscriptionsStore.h"
#import "TVHMuxStore.h"
#import "TVHServiceStore.h"
#import "TVHAdaptersStore.h"
#import "TVHStatusInputStore.h"
#import "TVHLogStore.h"
#import "TVHCometPoll.h"
#import "TVHConfigNameStore.h"
#import "TVHJsonClient.h"
#import "TVHApiClient.h"
#import "TVHModelAnalyticsProtocol.h"
#import "TVHPlayStream.h"

@interface TVHServer : NSObject
@property (nonatomic, strong) TVHServerSettings *settings;
@property (nonatomic, strong) TVHPlayStream *playStream;
@property (nonatomic, weak) id<TVHModelAnalyticsProtocol> analytics;
- (TVHJsonClient*)jsonClient;
- (TVHApiClient*)apiClient;
- (id <TVHTagStore>)tagStore;
- (id <TVHChannelStore>)channelStore;
- (id <TVHDvrStore>)dvrStore;
- (id <TVHAutoRecStore>)autorecStore;
- (id <TVHStatusSubscriptionsStore>)statusStore;
- (id <TVHAdaptersStore>)adapterStore;
- (id <TVHMuxStore>)muxStore;
- (id <TVHServiceStore>)serviceStore;
- (TVHLogStore*)logStore;
- (id <TVHCometPoll>)cometStore;
- (TVHConfigNameStore*)configNameStore;
- (id <TVHStatusInputStore>)inputStore;
- (NSString*)version;
- (NSString*)realVersion;

- (TVHServer*)initWithSettings:(TVHServerSettings*)settings;
- (id <TVHEpgStore>)createEpgStoreWithName:(NSString*)statsName;
- (void)fetchServerVersion;
- (BOOL)isTranscodingCapable;
- (void)resetData;
- (NSString*)htspUrl;
- (NSString*)httpUrl;
@end
