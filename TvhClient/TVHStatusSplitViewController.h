//
//  TVHStatusSplitViewController.h
//  TvhClient
//
//  Created by Luis Fernandes on 5/19/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "UIViewController+JASidePanel.h"
#import "MGSplitViewController.h"

@class TVHWebLogViewController;

@interface TVHStatusSplitViewController : MGSplitViewController <MGSplitViewControllerDelegate>
@property (nonatomic, strong) UINavigationController *statusController;
@property (nonatomic, strong) UINavigationController *debugController;
@property (nonatomic, strong) TVHWebLogViewController *webController;
- (void)setSecondScreenAsDebug;
- (void)setSecondScreenAsWeb;
@end
