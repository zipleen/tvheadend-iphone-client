//
//  TVHRecordingsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/27/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHRecordingsViewController.h"
#import "CKRefreshControl.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"
#import "TVHDvrItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "TVHRecordingsDetailViewController.h"

@interface TVHRecordingsViewController ()
@property (strong, nonatomic) TVHDvrStore *dvrStore;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation TVHRecordingsViewController {
    NSDateFormatter *dateFormatter;
}

- (TVHDvrStore*) dvrStore {
    if ( _dvrStore == nil) {
        _dvrStore = [TVHDvrStore sharedInstance];
    }
    return _dvrStore;
}

- (void) receiveDvrNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"didSuccessDvrAction"] ) {
        if ( [notification.object isEqualToString:@"deleteEntry"]) {
            WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInView:self.view title:NSLocalizedString(@"Succesfully Deleted Recording", nil)];
            [notice show];
        }
        else if([notification.object isEqualToString:@"cancelEntry"]) {
            WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInView:self.view title:NSLocalizedString(@"Succesfully Canceled Recording", nil)];
            [notice show];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.dvrStore setDelegate:self];
    [self.dvrStore fetchDvr];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDvrNotification:)
                                                 name:@"didSuccessDvrAction"
                                               object:nil];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E d MMM, HH:mm"];
    
    //self.segmentedControl.arrowHeightFactor *= -1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dvrStore count:self.segmentedControl.selectedSegmentIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecordStoreTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    TVHDvrItem *dvrItem = [self.dvrStore objectAtIndex:indexPath.row forType:self.segmentedControl.selectedSegmentIndex];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *statusLabel = (UILabel *)[cell viewWithTag:102];
    UIImageView *channelImage = (UIImageView *)[cell viewWithTag:103];
    
    titleLabel.text = dvrItem.title;
    dateLabel.text = [NSString stringWithFormat:@"%@ (%d min)", [dateFormatter stringFromDate:dvrItem.start], dvrItem.duration/60 ];
    statusLabel.text = dvrItem.status;
    [channelImage setImageWithURL:[NSURL URLWithString:dvrItem.chicon] placeholderImage:[UIImage imageNamed:@"tv2.png"]];
    
    // rouding corners
    channelImage.layer.cornerRadius = 5.0;
    channelImage.layer.masksToBounds = YES;
    channelImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    channelImage.layer.borderWidth = 0.2;
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    [cell.contentView addSubview: separator];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        TVHDvrItem *dvrItem = [self.dvrStore objectAtIndex:indexPath.row forType:self.segmentedControl.selectedSegmentIndex];
        if ( self.segmentedControl.selectedSegmentIndex == 0 ) {
            [dvrItem cancelRecording];
        }
        if ( self.segmentedControl.selectedSegmentIndex == 1 || self.segmentedControl.selectedSegmentIndex == 2 ) {
            [dvrItem deleteRecording];
        }
        
        
        // because our recordings aren't really deleted right away, we won't have cute animations because we want confirmation that the recording was in fact removed
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }   
     
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"DvrDetailSegue"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHDvrItem *item = [self.dvrStore objectAtIndex:path.row forType:self.segmentedControl.selectedSegmentIndex];
        
        TVHRecordingsDetailViewController *vc = segue.destinationViewController;
        [vc setDvrItem:item];
    }
}

- (void)viewDidUnload {
    [self setSegmentedControl:nil];
    [self setTableView:nil];
    [self setDvrStore:nil];
    [super viewDidUnload];
}

- (IBAction)segmentedDidChange:(id)sender {
    
    [self.tableView reloadData];
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.dvrStore fetchDvr];
}

- (void)didLoadDvr {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didErrorDvrStore:(NSError *)error {
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.localizedDescription];
    [notice setSticky:true];
    [notice show];
    [self.refreshControl endRefreshing];
}
@end
