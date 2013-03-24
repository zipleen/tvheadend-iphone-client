//
//  TVHChannel.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
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
#import "TVHEpg.h"
#import "TVHPlayStreamDelegate.h"

@class TVHEpg;
@class TVHEpgStore;

@protocol TVHChannelDelegate <NSObject>
- (void)didLoadEpgChannel;
@optional
- (void)didErrorLoadingEpgChannel:(NSError*)error;
@end

@interface TVHChannel : NSObject <TVHPlayStreamDelegate>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic) int number;
@property (nonatomic, strong) NSData *image;
@property (nonatomic) NSInteger chid;
@property (nonatomic, strong) NSArray *tags;

- (void)setCh_icon:(NSString*)icon;
- (bool)hasTag:(NSInteger)tag;
- (NSString*)streamURL;
- (void)addEpg:(TVHEpg*)epg;
- (TVHEpg*)currentPlayingProgram;

- (void)downloadRestOfEpg;
- (void)resetChannelEpgStore;
- (NSInteger)countEpg;

- (NSDate*)dateForDay:(NSInteger)day;
- (NSArray*)programsForDay:(NSInteger)day;
- (TVHEpg*)programDetailForDay:(NSInteger)day index:(NSInteger)program;
- (NSInteger)numberOfProgramsInDay:(NSInteger)section;
- (NSInteger)totalCountOfDaysEpg;

- (void)setDelegate:(id <TVHChannelDelegate>) delegate;
- (void)didLoadEpg:(TVHEpgStore*)epgList;
@end
