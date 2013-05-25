//
//  TVHLeftMainMenuViewController.m
//  TvhClient
//
//  Created by zipleen on 5/15/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHLeftMainMenuViewController.h"
#import "TVHStatusSplitViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TVHSettings.h"

#define TVH_LEFT_LABELS @[ @"Channels", @"Recordings",  @"Status", @"Settings" ]
#define TVH_LEFT_PICS @[ @"comp_ipad.png", @"rec_ipad.png",  @"status_ipad.png", @"settings_ipad.png" ]

#define TVH_CENTER_CHANNELS 0
#define TVH_CENTER_RECORDINGS 1
#define TVH_CENTER_STATUS 2
#define TVH_CENTER_SETTINGS 3

@interface TVHLeftMainMenuViewController () 

@end

@implementation TVHLeftMainMenuViewController {
    UIView *bgColorView;
}

- (TVHChannelSplitViewController*)channelSplit {
    if ( ! _channelSplit ) {
        _channelSplit = [self.storyboard instantiateViewControllerWithIdentifier:@"channelSplitController"];
    }
    return _channelSplit;
}

- (TVHRecordingsDetailViewController*)recordController {
    if ( ! _recordController ) {
        _recordController = [self.storyboard instantiateViewControllerWithIdentifier:@"recordingNavController"];
    }
    return _recordController;
}

- (TVHStatusSplitViewController*)statusSplit {
    if ( ! _statusSplit ) {
        _statusSplit = [self.storyboard instantiateViewControllerWithIdentifier:@"statusSplitViewController"];
    }
    return _statusSplit;
}

- (TVHSettingsViewController*)settingsController {
    if ( ! _settingsController ) {
        _settingsController = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsScreen"];
    }
    return _settingsController;
}

- (TVHDebugLogViewController*)debugLogController {
    if ( ! _debugLogController ) {
        _debugLogController = [self.storyboard instantiateViewControllerWithIdentifier:@"debugNavigationController"];
    }
    return _debugLogController;
}

- (TVHStatusSubscriptionsViewController*)statusController {
    if ( ! _statusController ) {
        _statusController = [self.storyboard instantiateViewControllerWithIdentifier:@"statusViewController"];
    }
    return _statusController;
}

- (TVHChannelStoreViewController*)channelController {
    if ( ! _channelController ) {
        _channelController = [self.storyboard instantiateViewControllerWithIdentifier:@"channelController"];
    }
    return _channelController;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithRed:0.204 green:0.204 blue:0.204 alpha:1];
    
    bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorWithRed:0.133 green:0.133 blue:0.133 alpha:1]];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                           animated:NO
                     scrollPosition:UITableViewScrollPositionNone];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [TVH_LEFT_LABELS count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"leftMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *text = (UILabel *)[cell viewWithTag:100];
    UIImageView *image = (UIImageView *)[cell viewWithTag:101];
    
    text.text = [NSLocalizedString([TVH_LEFT_LABELS objectAtIndex:indexPath.row], nil) uppercaseString];
    image.image = [UIImage imageNamed:[TVH_LEFT_PICS objectAtIndex:indexPath.row]];
    
    image.layer.shadowColor = [UIColor blackColor].CGColor;
    image.layer.shadowOffset = CGSizeMake(0, 2);
    image.layer.shadowOpacity = 0.7f;
    image.layer.shadowRadius = 1.5;
    image.clipsToBounds = NO;
    image.contentMode = UIViewContentModeScaleAspectFit;
    
    cell.selectedBackgroundView = bgColorView;
    
    UIView *sepColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 1 * [[UIScreen mainScreen] scale])];
    [sepColor setBackgroundColor:[UIColor colorWithRed:0.212 green:0.212 blue:0.212 alpha:1]];
    [cell.contentView addSubview:sepColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == TVH_CENTER_CHANNELS ) {
        [self.sidePanelController setCenterPanel:self.channelSplit];
    }
    
    if( indexPath.row == TVH_CENTER_RECORDINGS ) {
        [self.sidePanelController setCenterPanel:self.recordController];
    }
    
    if( indexPath.row == TVH_CENTER_STATUS ) {
        [self.sidePanelController setCenterPanel:self.statusSplit];
    }
    
    if( indexPath.row == TVH_CENTER_SETTINGS ) {
        [self.sidePanelController setCenterPanel:self.settingsController];
    }
    [self setRightPanel:indexPath.row];
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setRightPanel:(NSInteger)row {
    int rightMenu = [[TVHSettings sharedInstance] splitRightMenu];
    if ( rightMenu == TVHS_SPLIT_RIGHT_MENU_DYNAMIC ) {
        if ( row == TVH_CENTER_CHANNELS ) {
            [self.sidePanelController setRightPanel:self.recordController];
        }
        if ( row == TVH_CENTER_RECORDINGS ) {
            [self.sidePanelController setRightPanel:self.channelController];
        }
        if ( row == TVH_CENTER_STATUS ) {
            [self.sidePanelController setRightPanel:self.debugLogController];
        }
    }
    
    if ( rightMenu == TVHS_SPLIT_RIGHT_MENU_STATUS ) {
        [self.sidePanelController setRightPanel:self.statusController];
    }
    
    if ( rightMenu == TVHS_SPLIT_RIGHT_MENU_LOG ) {
        [self.sidePanelController setRightPanel:self.debugLogController];
    }
}

@end
