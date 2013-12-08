//
//  TVHStatusSplitViewController.m
//  TvhClient
//
//  Created by Luis Fernandes on 5/19/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHStatusSplitViewController.h"
#import "TVHDebugLogViewController.h"
#import "TVHStatusSubscriptionsViewController.h"
#import "TVHWebLogViewController.h"
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
        if ( [_statusController isKindOfClass:[UINavigationController class]] ) {
            TVHStatusSubscriptionsViewController *statusLog = [_statusController.childViewControllers lastObject];
            [statusLog setSplitViewController:self];
        }
    }
    return _statusController;
}

- (TVHWebLogViewController*)webController {
    if ( ! _webController ) {
        _webController = [self.storyboard instantiateViewControllerWithIdentifier:@"webNavigationController"];
        //if ( [_webController isKindOfClass:[UINavigationController class]] ) {
            //TVHWebLogViewController *webLog = [_webController.childViewControllers lastObject];
            [_webController setSplitViewController:self];
        //}
    }
    return _webController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.viewControllers = @[ self.debugController,  self.statusController ];
    self.vertical = NO;
    self.masterBeforeDetail = NO;
    self.delegate = self;
    [self showStatusLog];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setLogSplitPosition) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)setSecondScreenAsDebug {
    self.viewControllers = @[ self.debugController, self.statusController ];
}

- (void)setSecondScreenAsWeb {
    self.viewControllers = @[ self.webController, self.statusController ];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setLogSplitPosition];
}

- (void)showStatusLog {
    if ( [[TVHSettings sharedInstance] statusShowLog] ) {
        self.showsMasterInLandscape = YES;
        self.showsMasterInPortrait = YES;
    } else {
        self.showsMasterInLandscape = NO;
        self.showsMasterInPortrait = NO;
    }
}

- (void)setLogSplitPosition {
    if ( self.landscape ) {
        self.splitPosition = [[TVHSettings sharedInstance] statusSplitPosition];
    } else {
        self.splitPosition = [[TVHSettings sharedInstance] statusSplitPositionPortrait];
    }
}

- (void)splitViewController:(MGSplitViewController*)svc willMoveSplitToPosition:(float)position {
    if ( self.landscape ) {
        [[TVHSettings sharedInstance] setStatusSplitPosition:position];
    } else {
        [[TVHSettings sharedInstance] setStatusSplitPositionPortrait:position];
    }
}

@end
