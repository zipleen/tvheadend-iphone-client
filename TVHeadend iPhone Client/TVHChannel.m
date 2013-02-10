//
//  Channel.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannel.h"
#import "TVHSettings.h"

@interface TVHChannel()
@property (nonatomic, strong) NSMutableArray *schedulePrograms;
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
@end
