//
//  TVHEpgStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"

#define MAX_REQUEST_EPG_ITEMS 300 // tvheadend has a limit of how much items you can request at one time
#define DEFAULT_REQUEST_EPG_ITEMS 50 // this is the default query limit on the webUI
#define SECONDS_TO_FETCH_AHEAD_EPG_ITEMS 21600

@class TVHServer;
@class TVHEpgStore;

@protocol TVHEpgStoreDelegate <NSObject>
- (void)didLoadEpg:(TVHEpgStore*)epgStore;
@optional
- (void)willLoadEpg;
- (void)didErrorLoadingEpgStore:(NSError*)error;
@end

@interface TVHEpgStore : NSObject
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, strong) NSString *statsEpgName;
@property (nonatomic, strong) NSString *filterToProgramTitle;
@property (nonatomic, strong) NSString *filterToChannelName;
@property (nonatomic, strong) NSString *filterToTagName;
@property (nonatomic, strong) NSString *filterToContentTypeId;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (id)initWithStatsEpgName:(NSString*)statsEpgName withTvhServer:(TVHServer*)tvhServer;
- (void)downloadAllEpgItems;
- (void)downloadEpgList;
- (void)downloadMoreEpgList;
- (void)clearEpgData;
- (NSArray*)epgStoreItems;
- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate;
- (void)removeOldProgramsFromStore;
- (BOOL)isLastEpgFromThePast;
@end
