//
//  TVHChannelEpg.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/11/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHChannelEpg.h"

@implementation TVHChannelEpg

- (NSMutableArray*)programs {
    if (!_programs) {
        _programs = [[NSMutableArray alloc] init];
    }
    return _programs;
}

- (void)dealloc {
    self.programs = nil;
    self.date = nil;
}

@end
