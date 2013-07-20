//
//  TVHUICustomNavigationBar.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/23/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHUICustomNavigationBar.h"

@implementation TVHUICustomNavigationBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customize];
    }
    return self;
}

- (void)customize {
    if ( ! DEVICE_HAS_IOS7 ) {
        //UIImage *navBarBg = [UIImage imageNamed:@"navigationbar.png"];
        //[self setBackgroundImage:navBarBg forBarMetrics:UIBarMetricsDefault];
        [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor colorWithRed:200.0f/255.0f
                                                      green:200.0f/255.0f
                                                       blue:200.0f/255.0f
                                                      alpha:1.0],
                                      UITextAttributeTextColor,
                                      nil]];
        
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"navigationbar.png"]
                                                          resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)]
                                           forBarMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"UINavigationBarBlackOpaqueBack.png"]
                                                                    resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)]
                                                          forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsDefault];
        //[[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"UINavigationBarBlackOpaqueBackPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"UINavigationBarBlackOpaqueButton.png"]
                                                forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];
        //[[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"UINavigationBarBlackOpaqueButtonPressed.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [[UIProgressView appearance] setTrackImage:[[UIImage imageNamed:@"BarTrack.png"]
                                                    resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)]];
        [[UIProgressView appearance] setProgressImage:[[UIImage imageNamed:@"BarFill.png"]
                                                       resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)]];
        
        [[UIToolbar appearance] setBackgroundImage:[[UIImage
                                                     imageNamed:@"navigationbar_inverted.png"]
                                                        resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)]
                                forToolbarPosition:UIToolbarPositionAny
                                        barMetrics:UIBarMetricsDefault];
        
        [[UISearchBar appearance] setBackgroundImage:[[UIImage imageNamed:@"navigationbar.png"]
                                                     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)]
                                  ];
    }
}


@end
