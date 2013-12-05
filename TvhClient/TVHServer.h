//
//  TVHServer.h
//  TvhClient
//
//  Created by zipleen on 16/05/2013.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHTagStore.h"
#import "TVHChannelStore.h"
#import "TVHEpgStore.h"
#import "TVHDvrStore.h"
#import "TVHAutoRecStore.h"
#import "TVHStatusSubscriptionsStore.h"
#import "TVHAdaptersStore.h"
#import "TVHLogStore.h"
#import "TVHCometPollStore.h"
#import "TVHConfigNameStore.h"
#import "TVHJsonClient.h"
#import "TVHApiClient.h"
#import "TVHSettings.h"

@interface TVHServer : NSObject

- (id <TVHTagStore>)tagStore;
- (id <TVHChannelStore>)channelStore;
- (id <TVHDvrStore>)dvrStore;
- (TVHAutoRecStore*)autorecStore;
- (id <TVHStatusSubscriptionsStore>)statusStore;
- (id <TVHAdaptersStore>)adapterStore;
- (TVHLogStore*)logStore;
- (TVHCometPollStore*)cometStore;
- (TVHJsonClient*)jsonClient;
- (TVHApiClient*)apiClient;
- (TVHConfigNameStore*)configNameStore;
- (NSString*)version;
- (NSString*)realVersion;

- (TVHServer*)initVersion:(NSString*)version;
- (id <TVHEpgStore>)createEpgStoreWithName:(NSString*)statsName;
- (void)fetchServerVersion;
- (BOOL)isTranscodingCapable;
- (void)resetData;
- (NSString*)htspUrl;
- (NSString*)baseUrl;
@end
