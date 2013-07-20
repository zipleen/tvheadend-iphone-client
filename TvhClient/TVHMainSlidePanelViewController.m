//
//  TVHMainSlidePanelViewController.m
//  TvhClient
//
//  Created by zipleen on 5/15/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHMainSlidePanelViewController.h"
#import "TVHLeftMainMenuViewController.h"

@interface TVHMainSlidePanelViewController ()
@property (nonatomic, strong) TVHLeftMainMenuViewController *leftMainMenu;
@property (nonatomic, strong) TVHChannelSplitViewController *channelSplit;
@property (nonatomic, strong) TVHDebugLogViewController *statusSplit;
@end

@implementation TVHMainSlidePanelViewController

- (TVHLeftMainMenuViewController*)leftMainMenu {
    if ( ! _leftMainMenu ) {
        _leftMainMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMainMenu"];
    }
    return _leftMainMenu;
}

- (void)awakeFromNib
{
    self.leftFixedWidth = 90;
    self.rightFixedWidth = 500;
    //self.rightFixedWidth = 700;
    
    self.shouldResizeLeftPanel = YES;
    self.shouldResizeRightPanel = YES;
    
    self.bounceOnSidePanelClose = YES;
    self.bounceOnSidePanelOpen = YES;
    self.bounceOnCenterPanelChange = NO;
    
    self.allowLeftOverpan = NO;
    self.allowRightOverpan = NO;
    
    self.shouldDelegateAutorotateToVisiblePanel = NO;
    self.panningLimitedToTopViewController = NO;
    self.minimumMovePercentage = 0.05f;
    
    [self setLeftPanel:self.leftMainMenu];
    [self setCenterPanel:[self.leftMainMenu channelSplit] ];
    [self.leftMainMenu setRightPanel:0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
