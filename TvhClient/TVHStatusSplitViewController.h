//
//  TVHStatusSplitViewController.h
//  TvhClient
//
//  Created by zipleen on 5/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
#import "UIViewController+JASidePanel.h"
#import "MGSplitViewController.h"

@interface TVHStatusSplitViewController : MGSplitViewController <MGSplitViewControllerDelegate>
@property (nonatomic, strong) UINavigationController *statusController;
@property (nonatomic, strong) UINavigationController *debugController;
@end
