//
//  TVHStatusBar.m
//  TvhClient
//
//  Created by zipleen on 9/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
