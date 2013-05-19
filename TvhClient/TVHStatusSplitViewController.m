//
//  TVHStatusSplitViewController.m
//  TvhClient
//
//  Created by zipleen on 5/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHStatusSplitViewController.h"

@interface TVHStatusSplitViewController ()

@end

@implementation TVHStatusSplitViewController

- (TVHDebugLogViewController*)debugController {
    if ( ! _debugController ) {
        _debugController = [self.storyboard instantiateViewControllerWithIdentifier:@"debugNavigationController"];
    }
    return _debugController;
}

- (TVHStatusSubscriptionsViewController*)statusController {
    if ( ! _statusController ) {
        _statusController = [self.storyboard instantiateViewControllerWithIdentifier:@"statusViewController"];
    }
    return _statusController;
}

- (void)viewDidLoad
{
    CGRect divRect = self.view.bounds;
    divRect.size.width = 400;
    self.view.bounds = divRect;
    
    [super viewDidLoad];
	self.viewControllers = @[ self.statusController, self.debugController ];
    self.vertical = NO;
    self.showsMasterInLandscape = YES;
    self.showsMasterInPortrait = YES;
    //self.allowsDraggingDivider = YES;
    self.splitPosition = 485;
    //[self setDividerStyle:MGSplitViewDividerStylePaneSplitter animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
