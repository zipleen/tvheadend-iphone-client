//
//  Channel.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHEpg.h"

@class TVHEpg;
@class TVHEpgStore;

@protocol TVHChannelDelegate <NSObject>
- (void) didLoadEpgChannel;
@optional
-(void) didErrorLoadingEpgChannel:(NSError*)error;
@end

@interface TVHChannel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *imageUrl;
@property int number;
@property (nonatomic, strong) NSData *image;
@property (nonatomic) NSInteger chid;
@property (nonatomic, strong) NSArray *tags;

- (void)setCh_icon:(NSString*)icon;
- (bool) hasTag:(NSInteger)tag;
- (NSString*) streamURL;
- (void) addEpg:(TVHEpg*)epg;
- (TVHEpg*) currentPlayingProgram;

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
