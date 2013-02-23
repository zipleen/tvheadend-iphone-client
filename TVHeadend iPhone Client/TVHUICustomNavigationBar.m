//
//  TVHUICustomNavigationBar.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/23/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHUICustomNavigationBar.h"

@implementation TVHUICustomNavigationBar

+ (void)initialize {
    const CGFloat ArrowLeftCap = 14.0f;
    UIImage *back = [UIImage imageNamed:@"nav-backbutton.png"];
    back = [back stretchableImageWithLeftCapWidth:ArrowLeftCap
                                     topCapHeight:0];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[TVHUICustomNavigationBar class], nil] setBackButtonBackgroundImage:back
                                                                                                      forState:UIControlStateNormal
                                                                                                    barMetrics:UIBarMetricsDefault];
    
    /*const CGFloat TextOffset = 3.0f;
    [[UIBarButtonItem appearanceWhenContainedIn:[TVHUICustomNavigationBar class], nil] setBackButtonTitlePositionAdjustment:UIOffsetMake(TextOffset, 0)
                                                                                                         forBarMetrics:UIBarMetricsDefault];
     */
}

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
    UIImage *navBarBg = [UIImage imageNamed:@"navigationbar.png"];
    [self setBackgroundImage:navBarBg forBarMetrics:UIBarMetricsDefault];
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  [UIColor lightGrayColor], UITextAttributeTextColor,
                                  
                                  nil]];
}


@end
