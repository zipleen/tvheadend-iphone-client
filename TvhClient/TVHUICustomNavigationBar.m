//
//  TVHUICustomNavigationBar.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/23/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHUICustomNavigationBar.h"

@implementation TVHUICustomNavigationBar

+ (void)initialize {
    /*const CGFloat ArrowLeftCap = 14.0f;
    UIImage *back = [UIImage imageNamed:@"nav-backbutton.png"];
    back = [back stretchableImageWithLeftCapWidth:ArrowLeftCap
                                     topCapHeight:0];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[TVHUICustomNavigationBar class], nil] setBackButtonBackgroundImage:back
                                                                                                      forState:UIControlStateNormal
                                                                                                    barMetrics:UIBarMetricsDefault];
    
    const CGFloat TextOffset = 3.0f;
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
                                  [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0], UITextAttributeTextColor,
                                  nil]];
    
}


@end
