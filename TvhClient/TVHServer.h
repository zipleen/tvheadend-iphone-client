//
//  TVHServer.h
//  TvhClient
//
//  Created by zipleen on 16/05/2013.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
@property (nonatomic, strong) TVHChannelStore *channelStore;
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
- (TVHServer*)initVersion:(NSString*)version;
- (void)fetchServerVersion;
@end
