//
//  TVHEpgStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"

@class TVHServer;
@class TVHEpgStore;

@protocol TVHEpgStoreDelegate <NSObject>
- (void)didLoadEpg:(TVHEpgStore*)epgStore;
@optional
- (void)didErrorLoadingEpgStore:(NSError*)error;
@end

@interface TVHEpgStore : NSObject
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, strong) NSString *statsEpgName;
@property (nonatomic, strong) NSString *filterToChannelName;
@property (nonatomic, strong) NSString *filterToProgramTitle;
@property (nonatomic, strong) NSString *filterToTagName;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (id)initWithStatsEpgName:(NSString*)statsEpgName withTvhServer:(TVHServer*)tvhServer;
- (void)downloadAllEpgItems;
- (void)downloadEpgList;
- (void)downloadMoreEpgList;
- (NSArray*)epgStoreItems;
- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate;
@end
