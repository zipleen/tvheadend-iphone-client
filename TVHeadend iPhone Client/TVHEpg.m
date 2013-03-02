//
//  TVHEpg.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpg.h"
#import "TVHDvrActions.h"

@implementation TVHEpg

- (void) setStartFromInteger:(NSInteger)start {
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:start];
    _start = localDate;
}

- (void) setEndFromInteger:(NSInteger)end {
    NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:end];
    _end = localDate;
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

@end
