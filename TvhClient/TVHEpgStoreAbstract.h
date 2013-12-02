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
#import "TVHEpgStore.h"

@class TVHServer;
@class TVHEpgStore;

@interface TVHEpgStoreAbstract : NSObject <TVHEpgStore>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, strong) NSString *statsEpgName;
- (id)initWithStatsEpgName:(NSString*)statsEpgName withTvhServer:(TVHServer*)tvhServer;
- (NSString*)getApiEpg;

- (void)setFilterToProgramTitle:(NSString *)filterToProgramTitle;
- (void)setFilterToChannelName:(NSString *)filterToChannelName;
- (void)setFilterToTagName:(NSString *)filterToTagName;
- (void)setFilterToContentTypeId:(NSString *)filterToContentTypeId;

- (void)downloadAllEpgItems;
- (void)downloadEpgList;
- (void)downloadMoreEpgList;
- (void)clearEpgData;
- (NSArray*)epgStoreItems;
- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate;
- (void)removeOldProgramsFromStore;
- (BOOL)isLastEpgFromThePast;
@end
