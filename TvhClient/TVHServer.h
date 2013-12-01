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
#import "TVHDvrStore.h"
#import "TVHDvrStore32.h"
#import "TVHAutoRecStore.h"
#import "TVHStatusSubscriptionsStore.h"
#import "TVHAdaptersStore.h"
#import "TVHLogStore.h"
#import "TVHCometPollStore.h"
#import "TVHConfigNameStore.h"
#import "TVHJsonClient.h"
#import "TVHSettings.h"

@interface TVHServer : NSObject
@property (nonatomic, strong) TVHJsonClient *jsonClient;
@property (nonatomic, strong) TVHTagStore *tagStore;
@property (nonatomic, strong) id <TVHChannelStore> channelStore;
@property (nonatomic, strong) id <TVHDvrStore> dvrStore;
@property (nonatomic, strong) TVHAutoRecStore *autorecStore;
@property (nonatomic, strong) TVHStatusSubscriptionsStore *statusStore;
@property (nonatomic, strong) TVHAdaptersStore *adapterStore;
@property (nonatomic, strong) TVHLogStore *logStore;
@property (nonatomic, strong) TVHCometPollStore *cometStore;
@property (nonatomic, strong) TVHConfigNameStore *configNameStore;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *realVersion;
@property (nonatomic, strong) NSArray *capabilities;
@property (nonatomic, strong) NSDictionary *configSettings;
- (TVHServer*)initVersion:(NSString*)version;
- (void)fetchServerVersion;
- (BOOL)isTranscodingCapable;
- (void)resetData;
- (NSString*)htspUrl;
- (NSString*)baseUrl;
@end
