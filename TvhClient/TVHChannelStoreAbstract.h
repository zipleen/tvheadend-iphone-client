//
//  TVHChannelStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/. 
//

#import "TVHChannelStore.h"
#import "TVHEpgStore.h"

@interface TVHChannelStoreAbstract : NSObject <TVHChannelStore, TVHEpgStoreDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHChannelStoreDelegate> delegate;
@property (nonatomic) NSInteger filterTag;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchChannelList;
- (NSString*)getApiChannels;

- (NSArray*)channels;
- (NSArray*)arrayChannels;
- (TVHChannel*)channelWithName:(NSString*)name;
- (TVHChannel*)channelWithId:(NSString*)channelId;
- (NSArray*)filteredChannelList;
- (void)updateChannelsProgress;
@end
