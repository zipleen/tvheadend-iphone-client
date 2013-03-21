//
//  TVHDvrItem.m
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

#import "TVHDvrItem.h"
#import "TVHDvrActions.h"
#import "TVHChannelStore.h"
#import "TVHSettings.h"

@implementation TVHDvrItem

- (void)dealloc {
    self.channel = nil;
    self.chicon = nil;
    self.config_name = nil;
    self.description = nil;
    self.start = nil;
    self.end = nil;
    self.creator = nil;
    self.pri = nil;
    self.status = nil;
    self.schedstate = nil;
    self.url = nil;
    self.episode = nil;
}

- (NSString*)fullTitle {
    NSString *episode = self.episode;
    if ( episode == nil ) {
        episode = @"";
    }
    
    return [NSString stringWithFormat:@"%@ %@", self.title, episode];
}

- (void)setStart:(id)startDate {
    if( ! [startDate isKindOfClass:[NSString class]] ) {
        _start = [NSDate dateWithTimeIntervalSince1970:[startDate intValue]];
    }
}

- (void)setEnd:(id)endDate {
    if( ! [endDate isKindOfClass:[NSString class]] ) {
        _end = [NSDate dateWithTimeIntervalSince1970:[endDate intValue]];
    }
}

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (void)deleteRecording {
    if ( [self.schedstate isEqualToString:@"scheduled"] || [self.schedstate isEqualToString:@"recording"] ) {
        [TVHDvrActions cancelRecording:self.id];
    } else {
        [TVHDvrActions deleteRecording:self.id];
    }
}

- (TVHChannel*)channelObject {
    TVHChannelStore *store = [TVHChannelStore sharedInstance];
    TVHChannel *channel = [store channelWithName:self.channel];
    return channel;
}

- (NSString*)streamURL {
    if ( self.url && ![self.url isEqualToString:@"(null)"]) {
        TVHSettings *tvh = [TVHSettings sharedInstance];
        return [NSString stringWithFormat:@"%@/%@", tvh.baseURL, self.url];
    }
    return nil;
}

@end
