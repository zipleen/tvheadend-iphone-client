//
//  TVHLeftMainMenuViewController.m
//  TvhClient
//
//  Created by zipleen on 5/15/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHLeftMainMenuViewController.h"
#import "TVHStatusSplitViewController.h"



#define TVH_LEFT_LABELS @[ @"Channels", @"Recordings",  @"Status", @"Settings" ]
#define TVH_LEFT_PICS @[ @"comp.png", @"rec.png",  @"status.png", @"settings.png" ]

@interface TVHLeftMainMenuViewController () 

@end

@implementation TVHLeftMainMenuViewController {
    UIImageView *selectedTableCell;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"low_contrast_linen.png"]];
    
    UIImage *selImage = [UIImage imageNamed:@"random_grey_variations_sel.png"];
    selectedTableCell = [[UIImageView alloc] initWithImage:[selImage resizableImageWithCapInsets:UIEdgeInsetsZero]];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                           animated:NO
                     scrollPosition:UITableViewScrollPositionMiddle];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    text.text = NSLocalizedString([TVH_LEFT_LABELS objectAtIndex:indexPath.row], nil);
    image.image = [UIImage imageNamed:[TVH_LEFT_PICS objectAtIndex:indexPath.row]];
    cell.selectedBackgroundView = selectedTableCell;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == 0 ) {
        [self.sidePanelController setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"channelSplitController"]];
    }
    
    if( indexPath.row == 1 ) {
        [self.sidePanelController setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"recordingsSplitController"]];
    }
    
    if( indexPath.row == 2 ) {
        [self.sidePanelController setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"statusSplitViewController"]];
        
    }
    
    if( indexPath.row == 3 ) {
        [self.sidePanelController setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"settingsScreen"]];
    }
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
