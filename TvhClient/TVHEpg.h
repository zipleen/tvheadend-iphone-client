//
//  TVHEpg.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"

@class TVHChannel;

@interface TVHEpg : NSObject
@property (nonatomic) NSInteger channelId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic) NSInteger duration;
@property (nonatomic) NSInteger id;

@property (nonatomic, strong) NSString *chicon;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *episode;
@property (nonatomic, strong) NSString *serieslink;
@property (nonatomic, strong) NSString *contenttype;
@property (nonatomic, strong) NSString *schedstate;

- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (float)progress;
- (void)addRecording;
- (BOOL)isEqual:(TVHEpg*)other;
- (TVHChannel*)channelObject;
@end
