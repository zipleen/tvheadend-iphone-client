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
- (NSArray*)epgStoreItems;
- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate;
@end
