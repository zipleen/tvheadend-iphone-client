//
//  TVHEpg.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHEpg.h"
#import "TVHServer.h"
#import "TVHDvrActions.h"

@interface TVHEpg()
@property (nonatomic, weak) TVHServer *tvhServer;
@end

@implementation TVHEpg

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [self init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    
    return self;
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    // returns TVHEpg
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willRemoveEpgFromRecording:)
                                                 name:@"willRemoveEpgFromRecording"
                                               object:nil];
    
    // returns nsnumber
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSuccessfulyAddEpgToRecording:)
                                                 name:@"didSuccessfulyAddEpgToRecording"
                                               object:nil];
    return self;
}

// this one is wrong because I don't know if it actually removed recording or not! 
- (void)willRemoveEpgFromRecording:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"willRemoveEpgFromRecording"]) {
        TVHDvrItem *dvritem = [notification object];
        if ( [dvritem.channel isEqualToString:self.channel] && [dvritem.title isEqualToString:self.title] && [dvritem.start isEqual:self.start] ) {
            self.schedstate = nil;
            
            // update channels
            [[self.tvhServer channelStore] updateChannelsProgress];
            // update channel program detail view
            TVHChannel *ch = [[self.tvhServer channelStore] channelWithId:self.channelid];
            [ch signalDidLoadEpgChannel];
        }
    }
}

- (void)didSuccessfulyAddEpgToRecording:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"didSuccessfulyAddEpgToRecording"]) {
        NSNumber *number = [notification object];
        if ( [number intValue] == self.id ) {
            // not exactly right, but it's better than having to get ALL the epg again :p
            if ( [self progress] > 0 ) {
                self.schedstate = @"recording";
            } else {
                self.schedstate = @"scheduled";
            }
        
            // update channels
            [[self.tvhServer channelStore] updateChannelsProgress];
            // update channel program detail view
            TVHChannel *ch = [[self.tvhServer channelStore] channelWithId:self.channelid];
            [ch signalDidLoadEpgChannel];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.channel = nil;
    self.chicon = nil;
    self.title = nil;
    self.subtitle = nil;
    self.episode = nil;
    self.start = nil;
    self.end = nil;
    self.schedstate = nil;
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
    
    if( [now compare:self.start] == NSOrderedAscending ) {
#ifdef TESTING
        //NSLog(@"start(0) for %@ is %@", self.title, self.start);
#endif
        return 0;
    }
    if( [now compare:self.end] == NSOrderedDescending ) {
#ifdef TESTING
        //NSLog(@"start(1) for %@ is %@", self.title, self.start);
#endif
        return 1;
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
    TVHChannelStore *store = [self.tvhServer channelStore];
    TVHChannel *channel = [store channelWithId:self.channelid];
    return channel;
}

- (void)addAutoRec {
    [TVHDvrActions addAutoRecording:self.id withConfigName:nil];
}

- (BOOL)isScheduledForRecording {
    return [[self schedstate] isEqualToString:@"scheduled"];
}

- (BOOL)isRecording {
    return [[self schedstate] isEqualToString:@"recording"];
}

@end
