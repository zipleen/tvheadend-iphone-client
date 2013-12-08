//
//  TVHUICustomTabBarController.m
//  TvhClient
//
//  Created by Luis Fernandes on 01/08/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHUICustomTabBarController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface TVHUICustomTabBarController ()

@end

@implementation TVHUICustomTabBarController

#pragma MARK rotation

// iPad uses a different root controller! iPhone root controller is this one =)

// Autorotation (iOS <= 5.x)
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if ([self presentedViewController] && [[self presentedViewController] isKindOfClass:[MPMoviePlayerController class]]) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

// Autorotation (iOS >= 6.0)
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger orientations = UIInterfaceOrientationMaskPortrait;
    
    if ([self presentedViewController] && [[self presentedViewController] isKindOfClass:[MPMoviePlayerController class]]) {
        
        // Playing Video, additionally allow both landscape orientations:
        
        orientations |= UIInterfaceOrientationMaskLandscapeLeft;
        orientations |= UIInterfaceOrientationMaskLandscapeRight;
        
    }
    
    return orientations;
}
@end
