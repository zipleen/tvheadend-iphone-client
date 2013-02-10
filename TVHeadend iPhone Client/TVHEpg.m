//
//  TVHEpg.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpg.h"

@implementation TVHEpg
@synthesize channelId = _channelId;
@synthesize title = _title;
@synthesize description = _description;
@synthesize start = _start;
@synthesize end = _end;
@synthesize duration = _duration;

- (void) setStartFromInteger:(NSInteger)start {
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:start];
    _start = localDate;
}

- (void) setEndFromInteger:(NSInteger)end {
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:end];
    _end = localDate;
}

@end
