//
//  Channel.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannel.h"
#import "TVHEpgList.h"
#import "TVHChannelEpg.h"
#import "TVHSettings.h"

@interface TVHChannel() <TVHEpgListDelegate>
@property (nonatomic, strong) NSMutableArray *schedulePrograms;
@property (nonatomic, weak) id <TVHChannelDelegate> delegate;
@end

@implementation TVHChannel
@synthesize name = _name;
@synthesize detail = _detail;
@synthesize imageUrl = _imageUrl;
@synthesize number = _number;
@synthesize chid = _chid;
@synthesize tags = _tags;
@synthesize image = _image;
@synthesize schedulePrograms = _schedulePrograms;

-(NSMutableArray*) schedulePrograms{
    if(!_schedulePrograms) {
        _schedulePrograms = [[NSMutableArray alloc] init];
    }
    return _schedulePrograms;
}

-(void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    self.image = nil;
    //self.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageUrl]];
}

-(bool)hasTag:(NSInteger)tag {
    return [self.tags containsObject:[NSString stringWithFormat:@"%d",tag]];
}

-(NSString*)streamURL {
    TVHSettings *tvh = [TVHSettings sharedInstance];
    return [NSString stringWithFormat:@"%@/stream/channelid/%d?mux=pass", tvh.baseURL, self.chid];
}

-(TVHChannelEpg*) getObjectInsideSchedulePrograms:(NSString*)dateString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", dateString];
    NSArray *filteredArray = [self.schedulePrograms filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        return [filteredArray objectAtIndex:0];
    } else {
        TVHChannelEpg *tvh = [[TVHChannelEpg alloc] init];
        [tvh setDate:dateString];
        [self.schedulePrograms addObject:tvh];
        return tvh;
    }
}

-(void) addEpg:(TVHEpg*)epg {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yy";
    NSString *dateString = [dateFormatter stringFromDate:epg.start];
    
    TVHChannelEpg *tvhepg = [self getObjectInsideSchedulePrograms:dateString];
    [tvhepg.programs addObject:epg];
}

-(TVHEpg*) currentPlayingProgram {
    if ([self.schedulePrograms count]==0) {
        NSLog(@"No EPG for %@", self.name);
        return nil;
    }
    TVHChannelEpg *p = [self.schedulePrograms objectAtIndex:0];
    NSLog(@"Has %d for %@", [p.programs count] ,self.name);
    return [p.programs objectAtIndex:0];
}

- (NSComparisonResult)compareByName:(TVHChannel *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSInteger) countEpg {
    NSInteger count = 0;
    TVHChannelEpg *epg;
    NSEnumerator *e = [self.schedulePrograms objectEnumerator];
    while( epg = [e nextObject]) {
        count += [epg.programs count];
    }
    return count;
}

-(void) downloadRestOfEpg {
    // spawn a new epgList so we can set a filter to the channel
    TVHEpgList *epgList = [[TVHEpgList alloc] init];
    [epgList setDelegate:self];
    [epgList setFilterToChannelName:self.name];
    
    [epgList downloadEpgList];
}

-(NSArray*) programsForDay:(NSInteger)day {
    if ( [self.schedulePrograms count] == 0 ) {
        return nil;
    }
    
    return [[self.schedulePrograms objectAtIndex:day] copy];
    //NSArray *ordered = [self.schedulePrograms sortedArrayUsingSelector:@selector(compareByTime:)];
}

-(TVHEpg*) programDetailForDay:(NSInteger)day index:(NSInteger)program {
    return [[[self.schedulePrograms objectAtIndex:day] programs] objectAtIndex:program];
}

-(NSInteger) totalCountOfDaysEpg {
    return [self.schedulePrograms count];
}

-(NSString*) dateStringForDay:(NSInteger)day {
    TVHChannelEpg *epg = [self.schedulePrograms objectAtIndex:day];
    return [epg date];
}

-(NSInteger) numberOfProgramsInDay:(NSInteger)section{
    return [[[self.schedulePrograms objectAtIndex:section] programs] count];
}

- (void) didLoadEpg:(TVHEpgList*)epgList {
    NSArray *list = [epgList getEpgList];
    NSEnumerator *e = [list objectEnumerator];
    TVHEpg *epg;
    while( epg = [e nextObject]) {
        [self addEpg:epg];
    }
    [self.delegate didLoadEpgChannel];
}

- (void)setDelegate:(id <TVHChannelDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}
@end
