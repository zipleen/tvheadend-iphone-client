//
//  TVHStatusSplitViewController.m
//  TvhClient
//
//  Created by zipleen on 5/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHStatusSplitViewController.h"
#import "TVHSettings.h"

@interface TVHStatusSplitViewController ()

@end

@implementation TVHStatusSplitViewController

- (UINavigationController*)debugController {
    if ( ! _debugController ) {
        _debugController = [self.storyboard instantiateViewControllerWithIdentifier:@"debugNavigationController"];
        if ( [_debugController isKindOfClass:[UINavigationController class]] ) {
            TVHDebugLogViewController *debugLog = [_debugController.childViewControllers lastObject];
            [debugLog setSplitViewController:self];
        }
    }
    return _debugController;
}

- (UINavigationController*)statusController {
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
    
    self.splitPosition = [[TVHSettings sharedInstance] statusSplitPosition];
    self.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)splitViewController:(MGSplitViewController*)svc willMoveSplitToPosition:(float)position {
    [[TVHSettings sharedInstance] setStatusSplitPosition:position];
}


@end
