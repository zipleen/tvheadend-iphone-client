//
//  TVHEpg.h
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
@property (nonatomic, strong) NSString *serieslink;
@property (nonatomic, strong) NSString *contenttype;

- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (float)progress;
- (void)addRecording;
- (BOOL)isEqual:(TVHEpg*)other;
- (TVHChannel*)channelObject;
- (void)addAutoRec;
@end
