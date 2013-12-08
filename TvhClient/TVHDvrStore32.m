//
//  TVHDvrStore32.m
//  TvhClient
//
//  Created by Luis Fernandes on 7/9/13.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHDvrStore32.h"

@implementation TVHDvrStore32

- (TVHDvrItem*)createDvrItemFromDictionary:(NSDictionary*)obj ofType:(NSInteger)type {
    TVHDvrItem *dvritem = [[TVHDvrItem alloc] init];
    [dvritem updateValuesFromDictionary:obj];
    
    // 3.2 does not have the status divided, we need to make it happen
    NSString *schedstate = [dvritem schedstate];
    if ( [schedstate isEqualToString:@"scheduled"] ) {
        type = RECORDING_UPCOMING;
    }
    if ( [schedstate isEqualToString:@"recordingError"] ) {
        type = RECORDING_UPCOMING;
    }
    if ( [schedstate isEqualToString:@"recording"] ) {
        type = RECORDING_UPCOMING;
    }
    if ( [schedstate isEqualToString:@"completedError"] ) {
        type = RECORDING_FAILED;
    }
    if ( [schedstate isEqualToString:@"completed"] ) {
        type = RECORDING_FINISHED;
    }
    if ( [schedstate isEqualToString:@"unknown"] ) {
        type = RECORDING_FAILED;
    }
    [dvritem setDvrType:type];
    return dvritem;
}

- (void)fetchDvr {
    super.dvrItems = nil;
    super.cachedDvrItems = nil;
    
    [super fetchDvrItemsFromServer:@"dvrlist" withType:RECORDING_UPCOMING start:0 limit:20];
    [super signalDidLoadDvr:RECORDING_FINISHED];
    [super signalDidLoadDvr:RECORDING_FAILED];
}

@end
