//
//  TVHStatusSplitViewController.h
//  TvhClient
//
//  Created by zipleen on 5/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "MGSplitViewController.h"
#import "TVHStatusSubscriptionsViewController.h"
#import "TVHDebugLogViewController.h"

@interface TVHStatusSplitViewController : MGSplitViewController
@property (nonatomic, strong) TVHStatusSubscriptionsViewController *statusController;
@property (nonatomic, strong) TVHDebugLogViewController *debugController;
@end
