//
//  TVHDvrItem.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 28/02/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"
#import "TVHPlayStreamDelegate.h"

@interface TVHDvrItem : NSObject <TVHPlayStreamDelegate>
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *chicon;
@property (nonatomic, strong) NSString *config_name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic) NSInteger duration;
@property (nonatomic, strong) NSString *creator;
@property (nonatomic, strong) NSString *pri;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *schedstate;
@property (nonatomic) unsigned long long filesize;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) NSInteger dvrType;
@property (nonatomic, strong) NSString *episode;
- (NSString*)fullTitle;

- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (void)cancelRecording;
- (void)deleteRecording;
- (TVHChannel*)channelObject;
- (NSString*)streamURL;
@end
