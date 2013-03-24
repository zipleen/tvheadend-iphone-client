//
//  TVHChannel.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
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

#import "TVHChannel.h"
#import "TVHEpgStore.h"
#import "TVHChannelEpg.h"
#import "TVHSettings.h"

@interface TVHChannel() <TVHEpgStoreDelegate> {
    NSDateFormatter *dateFormatter;
}
@property (nonatomic, strong) NSMutableArray *channelEpgDataByDay;
@property (nonatomic, weak) id <TVHChannelDelegate> delegate;
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
    return [NSString stringWithFormat:@"%@/stream/channelid/%d", tvh.baseURL, self.chid];
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
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yy";
    }
    
    NSString *dateString = [dateFormatter stringFromDate:epg.start];
    
    TVHChannelEpg *tvhepg = [self getChannelEpgDataByDayString:dateString];
    
    // don't add duplicate epg - need to search in the array!
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"start == %@", epg.start];
    NSArray *filteredArray = [tvhepg.programs filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count] == 0) {
        [tvhepg.programs addObject:epg];

    }
}

- (TVHEpg*)currentPlayingProgram {
    if ([self.channelEpgDataByDay count]==0) {
#ifdef TESTING
        NSLog(@"No EPG for %@", self.name);
#endif
        return nil;
    }
    
    for ( TVHChannelEpg *epgByDay in self.channelEpgDataByDay ) {
        for ( TVHEpg *epg in [epgByDay programs] ) {
            if ( [epg progress] > 0 && [epg progress] < 100 ) {
                return epg;
            }
        }
    }
    return nil;
}

- (NSComparisonResult)compareByName:(TVHChannel *)otherObject {
    return [self.name compare:otherObject.name];
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
    // spawn a new epgList so we can set a filter to the channel
    TVHEpgStore *epgList = [[TVHEpgStore alloc] init];
    [epgList setDelegate:self];
    [epgList setFilterToChannelName:self.name];
    
    [epgList downloadEpgList];
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
    return [[[self.channelEpgDataByDay objectAtIndex:section] programs] count];
}

#pragma delegate stuff
- (void)didLoadEpg:(TVHEpgStore*)epgList {
    NSArray *list = [epgList epgStoreItems];
    NSEnumerator *e = [list objectEnumerator];
    TVHEpg *epg;
    while( epg = [e nextObject]) {
        [self addEpg:epg];
    }
    [self.delegate didLoadEpgChannel];
}

- (void)didErrorLoadingEpgStore:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorLoadingEpgChannel:)]) {
        [self.delegate didErrorLoadingEpgChannel:error];
    }
}

- (void)setDelegate:(id <TVHChannelDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}
@end
