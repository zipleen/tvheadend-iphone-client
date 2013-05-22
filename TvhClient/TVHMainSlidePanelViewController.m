//
//  TVHMainSlidePanelViewController.m
//  TvhClient
//
//  Created by zipleen on 5/15/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHMainSlidePanelViewController.h"

#import "TVHLeftMainMenuViewController.h"
#import "TVHDebugLogViewController.h"
#import "TVHChannelSplitViewController.h"

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

- (TVHChannelSplitViewController*)channelSplit {
    if ( ! _channelSplit ) {
        _channelSplit = [self.storyboard instantiateViewControllerWithIdentifier:@"channelSplitController"];
    }
    return _channelSplit;
}

- (TVHDebugLogViewController*)statusSplit {
    if ( ! _statusSplit ) {
        _statusSplit = [self.storyboard instantiateViewControllerWithIdentifier:@"debugNavigationController"];
    }
    return _statusSplit;
}

- (void)awakeFromNib
{
    self.leftFixedWidth = 160;
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
    [self setCenterPanel:self.channelSplit];
    [self setRightPanel:self.statusSplit];
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
