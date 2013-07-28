//
//  TVHEpg.h
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

@class TVHChannel;

@interface TVHEpg : NSObject
// channel
@property (nonatomic) NSInteger channelid;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *chicon;
// titles
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *episode;
- (NSString*)fullTitle;
// dates
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic) NSInteger duration;
// recording and metadata
@property (nonatomic, strong) NSString *schedstate;
@property (nonatomic) NSInteger serieslink;
@property (nonatomic, strong) NSString *contenttype;

- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (float)progress;
- (void)addRecording;
- (BOOL)isEqual:(TVHEpg*)other;
- (TVHChannel*)channelObject;
- (void)addAutoRec;
- (BOOL)isRecording;
- (BOOL)isScheduledForRecording;
@end
