//
//  TVHEpg.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpg.h"
#import "TVHDvrActions.h"
#import "TVHChannelStore.h"

@implementation TVHEpg

- (void)dealloc {
    self.channel = nil;
    self.chicon = nil;
    self.title = nil;
    self.subtitle = nil;
    self.episode = nil;
    self.start = nil;
    self.end = nil;
    self.schedstate = nil;
    self.serieslink = nil;
    self.contenttype = nil;
}

- (NSString*)fullTitle {
    /*
    NSString *subtitle = self.subtitle;
    if ( subtitle == nil ) {
        subtitle = @"";
    }
    */
    NSString *episode = self.episode;
    if ( episode == nil ) {
        episode = @"";
    }
    
    return [NSString stringWithFormat:@"%@ %@", self.title, episode];
}

- (void)setStart:(id)startDate {
    if([startDate isKindOfClass:[NSNumber class]]) {
        _start = [NSDate dateWithTimeIntervalSince1970:[startDate intValue]];
    }
}

- (void)setEnd:(id)endDate {
    if([endDate isKindOfClass:[NSNumber class]]) {
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

- (NSComparisonResult)compareByTime:(TVHEpg *)otherObject {
    return [self.start compare:otherObject.start];
}

- (float)progress {
    NSDate *now = [NSDate date];
    NSTimeInterval actualLength = [now timeIntervalSinceDate:self.start];
    NSTimeInterval programLength = [self.end timeIntervalSinceDate:self.start];
    
    if( [now compare:self.start] == NSOrderedAscending  ) {
        return 0;
    }
    if( [now compare:self.end] == NSOrderedDescending ) {
        return 100;
    }
    return actualLength / programLength;
}

- (void)addRecording {
    [TVHDvrActions addRecording:self.id withConfigName:nil];
}

- (BOOL)isEqual: (id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    TVHEpg *otherCast = other;
    return self.id == otherCast.id;
}

- (TVHChannel*)channelObject {
    TVHChannelStore *store = [TVHChannelStore sharedInstance];
    TVHChannel *channel = [store channelWithId:self.channelid];
    return channel;
}

@end
