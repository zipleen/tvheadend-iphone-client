//
//  TVHChannel.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHEpg.h"
#import "TVHPlayStreamDelegate.h"

@class TVHEpg;
@class TVHEpgStore;
@class TVHServer;

@protocol TVHChannelDelegate <NSObject>
@optional
- (void)didLoadEpgChannel;
- (void)didErrorLoadingEpgChannel:(NSError*)error;
@end

@interface TVHChannel : NSObject <TVHPlayStreamDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHChannelDelegate> delegate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic) int number;
@property (nonatomic, strong) NSData *image;
@property (nonatomic) NSInteger chid;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic) NSInteger epg_pre_start;
@property (nonatomic) NSInteger epg_post_end;
- (id)initWithTvhServer:(TVHServer*)tvhServer;

- (void)setCh_icon:(NSString*)icon;
- (bool)hasTag:(NSInteger)tag;
- (NSString*)streamURL;
- (NSString*)transcodeStreamURL;
- (void)addEpg:(TVHEpg*)epg;
- (TVHEpg*)currentPlayingProgram;
- (NSArray*)currentPlayingAndNextPrograms;

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
