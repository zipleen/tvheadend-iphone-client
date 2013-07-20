//
//  TVHDvrItem.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 28/02/13.
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
- (void)deleteRecording;
- (TVHChannel*)channelObject;
- (NSString*)streamURL;
- (NSString*)transcodeStreamURL;
@end
