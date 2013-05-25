//
//  TVHLeftMainMenuViewController.h
//  TvhClient
//
//  Created by zipleen on 5/15/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "TVHChannelSplitViewController.h"
#import "TVHChannelStoreViewController.h"
#import "TVHRecordingsDetailViewController.h"
#import "TVHStatusSplitViewController.h"
#import "TVHStatusSubscriptionsViewController.h"
#import "TVHDebugLogViewController.h"
#import "TVHSettingsViewController.h"

@interface TVHLeftMainMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) TVHChannelSplitViewController *channelSplit;
@property (nonatomic, strong) TVHRecordingsDetailViewController *recordController;
@property (nonatomic, strong) TVHStatusSplitViewController *statusSplit;
@property (nonatomic, strong) TVHSettingsViewController *settingsController;
@property (nonatomic, strong) TVHDebugLogViewController *debugLogController;
@property (nonatomic, strong) TVHStatusSubscriptionsViewController *statusController;
@property (nonatomic, strong) TVHChannelStoreViewController *channelController;
- (void)setRightPanel:(NSInteger)row;
@end
