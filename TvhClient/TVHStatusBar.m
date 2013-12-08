//
//  TVHStatusBar.m
//  TvhClient
//
//  Created by Luis Fernandes on 9/17/13.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHStatusBar.h"

@implementation TVHStatusBar
+ (void) clearStatusAnimated:(BOOL)animated {
    if ( ! DEVICE_HAS_IOS7 ) {
        [super clearStatusAnimated:animated];
    }
}

// each of the folowing methods resets progress
+ (void) setStatusText:(NSString *)text timeout:(NSTimeInterval)timeout animated:(BOOL)animated {
    if ( ! DEVICE_HAS_IOS7 ) {
        [super setStatusText:text timeout:timeout animated:animated];
    }
}

@end
