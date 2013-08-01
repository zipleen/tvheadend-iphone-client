//
//  TVHUICustomTabBarController.m
//  TvhClient
//
//  Created by zipleen on 01/08/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
        
        // Playing Video: Anything but 'Portrait (Upside down)' is OK
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else{
        // NOT Playing Video: Only 'Portrait' is OK
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
