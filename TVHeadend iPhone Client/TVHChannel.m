//
//  Channel.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannel.h"
#import "TVHEpgList.h"
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

-(void)addEpg:(TVHEpg*) epg {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"start == %@", epg.start];
    NSArray *filteredArray = [self.schedulePrograms filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count] == 0) {
        [self.schedulePrograms addObject:epg];
    }
}

-(NSString*) getCurrentPlayingProgram {
    NSLog(@"Has %d for %@", [self.schedulePrograms count] ,self.name);
    NSArray *ordered = [self.schedulePrograms sortedArrayUsingSelector:@selector(compareByTime:)];
    if([ordered count]>0) {
        TVHEpg *e = [ordered objectAtIndex:0];
        return e.title;
    }
    return nil;
}

- (NSComparisonResult)compareByName:(TVHChannel *)otherObject {
    return [self.name compare:otherObject.name];
}

-(NSArray*) getEpg {
    if( [self.schedulePrograms count] <= 1 ) {
        TVHEpgList *epgList = [[TVHEpgList alloc] init];
        [epgList setDelegate:self];
        [epgList setFilterToChannelName:self.name];
        
        [epgList downloadEpgList];
        
        // only 1 program, we can return the array
        return self.schedulePrograms;
    }
    
    NSArray *ordered = [self.schedulePrograms sortedArrayUsingSelector:@selector(compareByTime:)];
    return ordered;
}

-(NSInteger) countEpg {
    return [self.schedulePrograms count];
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
