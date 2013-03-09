//
//  TVHChannelEpg.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannelEpg.h"

@implementation TVHChannelEpg

- (NSMutableArray*) programs {
    if (!_programs) {
        _programs = [[NSMutableArray alloc] init];
    }
    return _programs;
}

@end
