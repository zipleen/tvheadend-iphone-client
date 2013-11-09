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

@class TVHEpgStore;
@class TVHServer;

@protocol TVHChannelDelegate <NSObject>
@optional
- (void)willLoadEpgChannel;
- (void)didLoadEpgChannel;
- (void)didErrorLoadingEpgChannel:(NSError*)error;
@end

@interface TVHChannel : NSObject <TVHPlayStreamDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHChannelDelegate> delegate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *ch_icon; // current image
@property (nonatomic, strong) NSString *chicon;  // original http image
@property (nonatomic) int number;
@property (nonatomic, strong) NSData *image;
@property (nonatomic) NSInteger chid;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic) NSInteger epg_pre_start;
@property (nonatomic) NSInteger epg_post_end;
@property (nonatomic, strong) NSString *epggrabsrc;
- (id)initWithTvhServer:(TVHServer*)tvhServer;

- (bool)hasTag:(NSInteger)tag;
- (NSString*)streamURL;
- (NSString*)playlistStreamURL;
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
- (void)removeOldProgramsFromStore;
- (BOOL)isLastEpgFromThePast;

- (void)setDelegate:(id <TVHChannelDelegate>) delegate;
- (void)didLoadEpg:(TVHEpgStore*)epgList;
- (void)signalDidLoadEpgChannel; // only to be used by tvhEpg
@end
