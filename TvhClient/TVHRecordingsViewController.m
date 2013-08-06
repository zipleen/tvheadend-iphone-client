//
//  TVHRecordingsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/27/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHRecordingsViewController.h"
#import "CKRefreshControl.h"
#import "TVHShowNotice.h"
#import "TVHSettings.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "TVHRecordingsDetailViewController.h"
#import "TVHAutoRecDetailViewController.h"
#import "NSString+FileSize.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "TVHImageCache.h"
#import "TVHSingletonServer.h"

#define SEGMENT_UPCOMING_REC 0
#define SEGMENT_COMPLETED_REC 1
#define SEGMENT_FAILED_REC 2
#define SEGMENT_AUTOREC 3

@interface TVHRecordingsViewController () {
    NIKFontAwesomeIconFactory *factory;
}

@property (weak, nonatomic) id <TVHDvrStore> dvrStore;
@property (weak, nonatomic) TVHAutoRecStore *autoRecStore;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation TVHRecordingsViewController {
    NSDateFormatter *dateFormatter;
}

- (id <TVHDvrStore>)dvrStore {
    if ( _dvrStore == nil) {
        _dvrStore = [[TVHSingletonServer sharedServerInstance] dvrStore];
    }
    return _dvrStore;
}

- (TVHAutoRecStore*)autoRecStore {
    if ( _autoRecStore == nil) {
        _autoRecStore = [[TVHSingletonServer sharedServerInstance] autorecStore];
    }
    return _autoRecStore;
}

- (void)receiveDvrNotification:(NSNotification *) notification {
    if ( [[notification name] isEqualToString:@"didSuccessDvrAction"] ) {
        if ( [notification.object isEqualToString:@"deleteEntry"]) {
            [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully Deleted Recording", nil)];
        }
        else if([notification.object isEqualToString:@"cancelEntry"]) {
            [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully Canceled Recording", nil)];
        }
    }
    // this is WRONG, there should be a specific notification for the autorec deleting
    if ( [[notification name] isEqualToString:@"didSuccessTableMgrAction"] ) {
        if ( [notification.object isEqualToString:@"delete"]) {
            [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully Deleted Auto Recording", nil)];
        }
    }
}

- (void)initDelegate {
    if( [self.dvrStore delegate] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLoadDvr:)
                                                     name:@"didLoadDvr"
                                                   object:self.dvrStore];
    } else {
        [self.dvrStore setDelegate:self];
    }

    if( [self.autoRecStore delegate] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLoadDvrAutoRec)
                                                     name:@"didLoadDvrAutoRec"
                                                   object:self.autoRecStore];
    } else {
        [self.autoRecStore setDelegate:self];
    }
}

- (void)resetRecordingsStore {
    [self initDelegate];
    [self.dvrStore fetchDvr];
    [self.autoRecStore fetchDvrAutoRec];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.dvrStore setDelegate:self];
    [self.dvrStore fetchDvr];
    
    [self.autoRecStore setDelegate:self];
    [self.autoRecStore fetchDvrAutoRec];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDvrNotification:)
                                                 name:@"didSuccessDvrAction"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDvrNotification:)
                                                 name:@"didSuccessTableMgrAction"
                                               object:nil];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E d MMM, HH:mm"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetRecordingsStore)
                                                 name:@"resetAllObjects"
                                               object:nil];
    
    factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    factory.size = 32*2;
    factory.colors = @[[UIColor grayColor]];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconTime] forSegmentAtIndex:0];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconOkCircle] forSegmentAtIndex:1];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconMagic] forSegmentAtIndex:3];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconExclamationSign] forSegmentAtIndex:2];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"Upcoming", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"Completed", nil) forSegmentAtIndex:1];
    [self.segmentedControl setTitle:NSLocalizedString(@"Failed", nil) forSegmentAtIndex:2];
    [self.segmentedControl setTitle:NSLocalizedString(@"AutoRec", nil) forSegmentAtIndex:3];
    
    self.title = NSLocalizedString(@"Recordings", @"");
    
    if ( ! IS_IPAD ) {
        UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(handleSwipeFromRight:)];
        [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.tableView addGestureRecognizer:rightGesture];
        
        UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(handleSwipeFromLeft:)];
        [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.tableView addGestureRecognizer:leftGesture];
    }
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSegmentedControl:nil];
    [self setTableView:nil];
    [self setDvrStore:nil];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    TVHSettings *settings = [TVHSettings sharedInstance];
    if ( [settings programFirstRun] ) {
        [self.segmentedControl setSelectedSegmentIndex:3 ];
    }
#ifdef TVH_GOOGLEANALYTICS_KEY
        [[GAI sharedInstance].defaultTracker sendView:NSStringFromClass([self class])];
#endif
    [self.tableView setEditing:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ( self.segmentedControl.selectedSegmentIndex == SEGMENT_AUTOREC ) {
        if ( [self.autoRecStore count] == 0 ) {
            return NSLocalizedString(@"No auto recordings found.", nil);
        }
    } else {
        if ( [self.dvrStore count:self.segmentedControl.selectedSegmentIndex] == 0 ) {
            return NSLocalizedString(@"No recordings found.", nil);
        }
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //create the uiview container
    UIView *tfooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 45)];
    tfooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    //create the uilabel for the text
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_tableView.frame.size.width/2-120, 0, 240, 35)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    label.numberOfLines = 2;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1];
    label.shadowColor = [UIColor whiteColor];
    label.text = [self tableView:self.tableView titleForFooterInSection:section];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    label.accessibilityLabel = [self tableView:self.tableView titleForFooterInSection:section];
    //add the label to the view
    [tfooterView addSubview:label];
    
    return tfooterView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( self.segmentedControl.selectedSegmentIndex == SEGMENT_AUTOREC ) {
        return [self.autoRecStore count];
    } else {
        return [self.dvrStore count:self.segmentedControl.selectedSegmentIndex];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecordStoreTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *statusLabel = (UILabel *)[cell viewWithTag:102];
    __weak UIImageView *channelImage = (UIImageView *)[cell viewWithTag:103];
    titleLabel.textColor = [UIColor blackColor];
    channelImage.contentMode = UIViewContentModeScaleAspectFit;
    
    if ( self.segmentedControl.selectedSegmentIndex == SEGMENT_AUTOREC ) {
        TVHAutoRecItem *autoRecItem = [self.autoRecStore objectAtIndex:indexPath.row];
        titleLabel.text = autoRecItem.title;
        dateLabel.text = autoRecItem.channel;
        statusLabel.text = [NSString stringOfWeekdaysLocalizedFromArray:[autoRecItem.weekdays componentsSeparatedByString:@","] joinedByString:@","];
        
        if (autoRecItem.channel) {
            TVHChannelStore *channelStore = [[self.dvrStore tvhServer] channelStore];
            TVHChannel *channel = [channelStore channelWithName:autoRecItem.channel];
            channelImage.contentMode = UIViewContentModeScaleAspectFit;
            [channelImage setImageWithURL:[NSURL URLWithString:channel.imageUrl] placeholderImage:[UIImage imageNamed:@"tv2.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (!error) {
                    channelImage.image = [TVHImageCache resizeImage:image];
                }
            } ];
        } else {
            [channelImage setImage:[UIImage imageNamed:@"tv2.png"]];
        }
        
        if ( [autoRecItem enabled] ) {
            titleLabel.textColor = [UIColor blackColor];
        } else {
            titleLabel.textColor = [UIColor grayColor];
        }
    } else {
        TVHDvrItem *dvrItem = [self.dvrStore objectAtIndex:indexPath.row forType:self.segmentedControl.selectedSegmentIndex];
        titleLabel.text = dvrItem.fullTitle;
        dateLabel.text = [NSString stringWithFormat:@"%@ (%d min)", [dateFormatter stringFromDate:dvrItem.start], dvrItem.duration/60 ];
        statusLabel.text = dvrItem.status;
        [channelImage setImageWithURL:[NSURL URLWithString:dvrItem.chicon] placeholderImage:[UIImage imageNamed:@"tv2.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (!error) {
                channelImage.image = [TVHImageCache resizeImage:image];
            }
        } ];
    }
        
    // rouding corners - this makes the animation in ipad become VERY SLOW!!!
    //channelImage.layer.cornerRadius = 5.0f;
    if ( [[TVHSettings sharedInstance] useBlackBorders] ) {
        channelImage.layer.masksToBounds = NO;
        channelImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        channelImage.layer.borderWidth = 0.4;
        channelImage.layer.shouldRasterize = YES;
    } else {
        channelImage.layer.borderWidth = 0;
    }
    
    UIView *sepColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 1)];
    [sepColor setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [cell.contentView addSubview:sepColor];
    
    //UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    //[cell.contentView addSubview: separator];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( IS_IPAD ) {
        if (self.editing) {
            return UITableViewCellEditingStyleDelete;
        }
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleDelete;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if ( self.segmentedControl.selectedSegmentIndex == SEGMENT_AUTOREC ) {
            TVHAutoRecItem *autoRecItem = [self.autoRecStore objectAtIndex:indexPath.row];
            [autoRecItem deleteAutoRec];
        } else {
            TVHDvrItem *dvrItem = [self.dvrStore objectAtIndex:indexPath.row forType:self.segmentedControl.selectedSegmentIndex];
            [dvrItem deleteRecording];
        }
#ifdef TVH_GOOGLEANALYTICS_KEY
        [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"uiAction"
                                                        withAction:@"recordings"
                                                         withLabel:@"removeRecording"
                                                         withValue:[NSNumber numberWithInt:0]];
#endif
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
    if( self.segmentedControl.selectedSegmentIndex == SEGMENT_AUTOREC ) {
        if ( [self.autoRecStore objectAtIndex:indexPath.row] ) {
            [self performSegueWithIdentifier:@"DvrAutoRecDetailSegue" sender:self];
        }
    } else {
        if ( [self.dvrStore objectAtIndex:indexPath.row forType:self.segmentedControl.selectedSegmentIndex] ) {
            [self performSegueWithIdentifier:@"DvrDetailSegue" sender:self];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"DvrDetailSegue"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHDvrItem *item = [self.dvrStore objectAtIndex:path.row forType:self.segmentedControl.selectedSegmentIndex];
        
        TVHRecordingsDetailViewController *vc = segue.destinationViewController;
        [vc setDvrItem:item];
    }
    if([segue.identifier isEqualToString:@"DvrAutoRecDetailSegue"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHAutoRecItem *item = [self.autoRecStore objectAtIndex:path.row];
        
        TVHAutoRecDetailViewController *vc = segue.destinationViewController;
        [vc setTitle:[item title]];
        [vc setItem:[item copy]];
    }
}

- (void)handleSwipeFromRight:(UISwipeGestureRecognizer *)recognizer {
    if ( recognizer.state == UIGestureRecognizerStateEnded ) {
        int sel = [self.segmentedControl selectedSegmentIndex] -1;
        if (sel >= 0 ) {
            [self.segmentedControl setSelectedSegmentIndex:sel];
            [self segmentedDidChange:self.segmentedControl];
        }
    }
}

- (void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)recognizer {
    if ( recognizer.state == UIGestureRecognizerStateEnded ) {
        int sel = [self.segmentedControl selectedSegmentIndex] + 1;
        if (sel < [self.segmentedControl numberOfSegments] ) {
            [self.segmentedControl setSelectedSegmentIndex:sel];
            [self segmentedDidChange:self.segmentedControl];
        }
    }
}

- (IBAction)segmentedDidChange:(id)sender {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.autoRecStore fetchDvrAutoRec];
    [self.dvrStore fetchDvr];
}

- (void)reloadData {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)willLoadDvr:(NSInteger)type {
    [WTStatusBar setStatusText:@"Loading DVR Data..." timeout:2.0 animated:YES];
}

- (void)willLoadDvrAutoRec {
    [WTStatusBar setStatusText:@"Loading AutoRec DVR Data..." timeout:2.0 animated:YES];
}

- (void)didLoadDvr:(NSInteger)type {
    if ( type == self.segmentedControl.selectedSegmentIndex ) {
        [WTStatusBar clearStatusAnimated:YES];
        [self reloadData];
    }
}

- (void)didLoadDvrAutoRec {
    if ( self.segmentedControl.selectedSegmentIndex == SEGMENT_AUTOREC ) {
        [WTStatusBar clearStatusAnimated:YES];
        [self reloadData];
    }
}

- (void)didErrorDvrStore:(NSError *)error {
    [TVHShowNotice errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.localizedDescription];
    [self.refreshControl endRefreshing];
}

- (void)didErrorDvrAutoStore:(NSError *)error {
    [self didErrorDvrStore:error];
}

- (IBAction)putTableInEditMode:(id)sender {
    if ( [self.tableView isEditing] ) {
        [self.tableView setEditing: NO animated: YES];
    } else {
        [self.tableView setEditing: YES animated: YES];
    }
    
}
@end
