//
//  TVHStatusSplitViewController.h
//  TvhClient
//
//  Created by zipleen on 5/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "UIViewController+JASidePanel.h"
#import "MGSplitViewController.h"

@interface TVHStatusSplitViewController : MGSplitViewController <MGSplitViewControllerDelegate>
@property (nonatomic, strong) UINavigationController *statusController;
@property (nonatomic, strong) UINavigationController *debugController;
@end
