//
//  TVHDvrItem.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 28/02/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHDvrItem.h"
#import "TVHDvrActions.h"
#import "TVHChannelStore.h"
#import "TVHSettings.h"

// to remove
#import "TVHSingletonServer.h"

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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willRemoveEpgFromRecording"
                                                        object:self];
}

- (TVHChannel*)channelObject {
    id <TVHChannelStore> store = [[TVHSingletonServer sharedServerInstance] channelStore];
    TVHChannel *channel = [store channelWithName:self.channel];
    return channel;
}

- (NSString*)streamURL {
    if ( self.url && ![self.url isEqualToString:@"(null)"]) {
        TVHSettings *tvh = [TVHSettings sharedInstance];
        return [NSString stringWithFormat:@"%@/%@", [tvh fullBaseURL], self.url];
    }
    return nil;
}

- (NSString*)playlistStreamURL {
    return nil;
}

- (NSString*)htspStreamURL {
    return nil;
}

- (BOOL)isEqual: (id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    TVHDvrItem *otherCast = other;
    return self.id == otherCast.id;
}
@end
