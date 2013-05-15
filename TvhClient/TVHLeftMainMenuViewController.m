//
//  TVHLeftMainMenuViewController.m
//  TvhClient
//
//  Created by zipleen on 5/15/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHLeftMainMenuViewController.h"

@interface TVHLeftMainMenuViewController ()

@end

@implementation TVHLeftMainMenuViewController

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == 0 ) {
        [self.sidePanelController setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"channelSplitController"]];
    }
    if( indexPath.row == 1 ) {
        [self.sidePanelController setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"recordingsSplitController"]];
    }
    if( indexPath.row == 2 ) {
        [self.sidePanelController setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"epgViewController"]];
    }
    if( indexPath.row == 3 ) {
        [self.sidePanelController setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"statusViewController"]];
    }
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
