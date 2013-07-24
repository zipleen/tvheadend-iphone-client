//
//  TVHChannel.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHChannel.h"
#import "TVHEpgStore.h"
#import "TVHChannelEpg.h"
#import "TVHSettings.h"
#import "TVHServer.h"

@interface TVHChannel() <TVHEpgStoreDelegate> {
    NSDateFormatter *dateFormatter;
}
@property (nonatomic, strong) NSMutableArray *channelEpgDataByDay;
@end

@implementation TVHChannel

- (void)dealloc {
    self.name = nil;
    self.detail = nil;
    self.imageUrl = nil;
    self.image = nil;
    self.tags = nil;
    self.channelEpgDataByDay = nil;
    dateFormatter = nil;
}

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;

    return self;
}

- (NSMutableArray*)channelEpgDataByDay{
    if(!_channelEpgDataByDay) {
        _channelEpgDataByDay = [[NSMutableArray alloc] init];
    }
    return _channelEpgDataByDay;
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    self.image = nil;
    //self.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageUrl]];
}

// notice that setTags has (id) instead of NSArray*, which means we can test for a NSString and convert it !
- (void)setTags:(id)tags {
    if([tags isKindOfClass:[NSString class]]) {
        _tags = [tags componentsSeparatedByString:@","];
    }
}

- (void)setCh_icon:(NSString*)icon {
    [self setImageUrl:icon];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (bool)hasTag:(NSInteger)tag {
    return [self.tags containsObject:[NSString stringWithFormat:@"%d",tag]];
}

- (NSString*)streamURL {
    TVHSettings *tvh = [TVHSettings sharedInstance];
    return [NSString stringWithFormat:@"%@/stream/channelid/%d", [tvh fullBaseURL], self.chid];
}

- (NSString*)transcodeStreamURL {
    if ( [self.tvhServer isTranscodingCapable] ) {
        TVHSettings *tvh = [TVHSettings sharedInstance];
        return [NSString stringWithFormat:@"%@/playlist/channelid/%d", [tvh fullBaseURL], self.chid];
    }
    return nil;
}

- (TVHChannelEpg*)getChannelEpgDataByDayString:(NSString*)dateString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", dateString];
    NSArray *filteredArray = [self.channelEpgDataByDay filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        return [filteredArray objectAtIndex:0];
    } else {
        TVHChannelEpg *tvh = [[TVHChannelEpg alloc] init];
        [tvh setDate:dateString];
        [self.channelEpgDataByDay addObject:tvh];
        return tvh;
    }
}

- (void)addEpg:(TVHEpg*)epg {
    if( !dateFormatter ) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yy";
    }
    
    NSString *dateString = [dateFormatter stringFromDate:epg.start];    
    TVHChannelEpg *tvhepg = [self getChannelEpgDataByDayString:dateString];
    
    // don't add duplicate epg - need to search in the array!
    if ( [tvhepg.programs indexOfObject:epg] == NSNotFound ) {
        [tvhepg.programs addObject:epg];
    }
}

- (TVHEpg*)currentPlayingProgram {
    if ( [self.channelEpgDataByDay count] == 0 ) {
#ifdef TESTING
        NSLog(@"No EPG data on array for %@", self.name);
#endif
        return nil;
    }
    
    for ( TVHChannelEpg *epgByDay in self.channelEpgDataByDay ) {
        for ( TVHEpg *epg in [epgByDay programs] ) {
            if ( [epg progress] > 0 && [epg progress] < 100 ) {
                return epg;
            }
#ifdef TESTING
            else {
                NSLog(@"progress for %@ : %f", epg.title, [epg progress]);
            }
#endif
        }
    }
#ifdef TESTING
    NSLog(@"Didn't find any EPG for %@", self.name);
#endif
    return nil;
}

- (NSArray*)currentPlayingAndNextPrograms {
    int i = 0;
    NSMutableArray *nextPrograms = [[NSMutableArray alloc] init];
    if ( [self.channelEpgDataByDay count] == 0 ) {
#ifdef TESTING
        NSLog(@"No EPG data on array for %@", self.name);
#endif
        return nil;
    }
    
    for ( TVHChannelEpg *epgByDay in self.channelEpgDataByDay ) {
        for ( TVHEpg *epg in [epgByDay programs] ) {
            [nextPrograms addObject:epg];
            i++;
            if ( i >= 3 ) {
                break;
            }
        }
    }
    return [nextPrograms copy];

}

- (NSComparisonResult)compareByName:(TVHChannel *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSComparisonResult)compareByNumber:(TVHChannel *)otherObject {
    if ( self.number < otherObject.number ) {
        return NSOrderedAscending;
    } else if ( self.number > otherObject.number ) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

- (void)resetChannelEpgStore {
    self.channelEpgDataByDay = nil;
}

- (NSInteger)countEpg {
    NSInteger count = 0;
    TVHChannelEpg *epg;
    NSEnumerator *e = [self.channelEpgDataByDay objectEnumerator];
    while( epg = [e nextObject]) {
        count += [epg.programs count];
    }
    return count;
}

- (void)downloadRestOfEpg {
    [self signalWillLoadEpgChannel];
    // spawn a new epgList so we can set a filter to the channel
    TVHEpgStore *restOfEpgStore = [[TVHEpgStore alloc] initWithStatsEpgName:@"ChannelEPG" withTvhServer:self.tvhServer];
    [restOfEpgStore setDelegate:self];
    [restOfEpgStore setFilterToChannelName:self.name];
    
    [restOfEpgStore downloadAllEpgItems];
}

#pragma Table Call Methods

- (NSArray*)programsForDay:(NSInteger)day {
    if ( [self.channelEpgDataByDay count] == 0 ) {
        return nil;
    }
    
    return [[self.channelEpgDataByDay objectAtIndex:day] copy];
    //NSArray *ordered = [self.channelEpgDataByDay sortedArrayUsingSelector:@selector(compareByTime:)];
}

- (TVHEpg*)programDetailForDay:(NSInteger)day index:(NSInteger)program {
    if ( day < [self.channelEpgDataByDay count] ) {
        if ( program < [[[self.channelEpgDataByDay objectAtIndex:day] programs] count] ){
            return [[[self.channelEpgDataByDay objectAtIndex:day] programs] objectAtIndex:program];
        }
    }
    return nil;
}

- (NSInteger)totalCountOfDaysEpg {
    return [self.channelEpgDataByDay count];
}

- (NSDate*)dateForDay:(NSInteger)day {
    TVHChannelEpg *epg = [self.channelEpgDataByDay objectAtIndex:day];
    TVHEpg *realEpg = [[epg programs] objectAtIndex:0];
    return [realEpg start];
}

- (NSInteger)numberOfProgramsInDay:(NSInteger)section{
    if ( [self.channelEpgDataByDay count] > section ) {
        return [[[self.channelEpgDataByDay objectAtIndex:section] programs] count];
    }
    return 0;
}

- (BOOL)isEqual: (id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    TVHChannel *otherCast = other;
    return self.chid == otherCast.chid;
}

#pragma delegate stuff
- (void)didLoadEpg:(TVHEpgStore*)epgStore {
    NSArray *epgItems = [epgStore epgStoreItems];
    for (TVHEpg *epg in epgItems) {
        [self addEpg:epg];
    }
    [self signalDidLoadEpgChannel];
}

- (void)didErrorLoadingEpgStore:(NSError*)error {
    [self signalDidErrorLoadingEpgChannel:error];
}

- (void)setDelegate:(id <TVHChannelDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)signalWillLoadEpgChannel {
    if ([self.delegate respondsToSelector:@selector(willLoadEpgChannel)]) {
        [self.delegate willLoadEpgChannel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willLoadEpgChannel"
                                                        object:self];
}

- (void)signalDidLoadEpgChannel {
    if ([self.delegate respondsToSelector:@selector(didLoadEpgChannel)]) {
        [self.delegate didLoadEpgChannel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadEpgChannel"
                                                        object:self];
}

- (void)signalDidErrorLoadingEpgChannel:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorLoadingEpgChannel:)]) {
        [self.delegate didErrorLoadingEpgChannel:error];
    }
}
@end
