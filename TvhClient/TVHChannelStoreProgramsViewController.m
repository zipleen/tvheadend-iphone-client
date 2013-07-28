//
//  TVHChannelListProgramsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHChannelStoreProgramsViewController.h"
#import "TVHProgramDetailViewController.h"
#import "TVHEpg.h"
#import "TVHShowNotice.h"
#import "CKRefreshControl.h"
#import "TVHPlayStreamHelpController.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "TVHProgressBar.h"

@interface TVHChannelStoreProgramsViewController () <TVHChannelDelegate, UIActionSheetDelegate> {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
    NIKFontAwesomeIconFactory *factory;
}
@property (strong, nonatomic) TVHPlayStreamHelpController *help;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation TVHChannelStoreProgramsViewController

- (void)viewDidAppear:(BOOL)animated
{
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker sendView:NSStringFromClass([self class])];
#endif
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                                    self.tableView);
}

- (void)initDelegate {
    if ( [self.channel delegate] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLoadEpgChannel)
                                                     name:@"didLoadEpgChannel"
                                                   object:self.channel];
    } else {
        [self.channel setDelegate:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    
    [self initDelegate];
    [self.channel downloadRestOfEpg];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE"];
    timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    
    factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    factory.size = 16;
    [self.navigationItem.rightBarButtonItem setImage:[factory createImageForIcon:NIKFontAwesomeIconFilm]];
    [self.navigationItem.rightBarButtonItem setAccessibilityLabel:NSLocalizedString(@"Play Channel", @"accessbility")];
    
    [self.segmentedControl removeAllSegments];
    [self updateSegmentControl];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

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

- (void)viewWillDisappear:(BOOL)animated {
    [self.help dismissActionSheet];
}

- (void)viewDidUnload
{
    [self setSegmentedControl:nil];
    [super viewDidUnload];
    self.channel = nil;
    dateFormatter = nil;
    timeFormatter = nil;
    self.help = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.channel resetChannelEpgStore];
    [self.tableView reloadData];
    [self.channel downloadRestOfEpg];
}

#pragma mark - Table view data source

- (void)handleSwipeFromRight:(UISwipeGestureRecognizer *)recognizer {
    if ( recognizer.state == UIGestureRecognizerStateEnded ) {
        int sel = [self.segmentedControl selectedSegmentIndex] -1;
        if (sel >= 0 ) {
            [self.segmentedControl setSelectedSegmentIndex:sel];
            [self.tableView reloadData];
        }
    }
}

- (void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)recognizer {
    if ( recognizer.state == UIGestureRecognizerStateEnded ) {
        int sel = [self.segmentedControl selectedSegmentIndex] + 1;
        if (sel < [self.segmentedControl numberOfSegments] ) {
            [self.segmentedControl setSelectedSegmentIndex:sel];
            [self.tableView reloadData];
        }
    }
}

- (void)updateSegmentControl {
    for (int i=0 ; i<[self.channel totalCountOfDaysEpg]; i++) {
        NSDate *date = [self.channel dateForDay:i];
        NSString *dateString = [dateFormatter stringFromDate:date];
        if ( i >= [self.segmentedControl numberOfSegments] ) {
            [self.segmentedControl insertSegmentWithTitle:dateString atIndex:i animated:YES];
        } else {
            if ( ! [[self.segmentedControl titleForSegmentAtIndex:i] isEqualToString:dateString] ) {
                [self.segmentedControl setTitle:dateString forSegmentAtIndex:i];
            }
        }
    }
    if ( self.segmentedControl.selectedSegmentIndex == -1 && [self.segmentedControl numberOfSegments] > 0 ) {
        [self.segmentedControl setSelectedSegmentIndex:0];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    uint selected = self.segmentedControl.selectedSegmentIndex;
    if ( self.segmentedControl.selectedSegmentIndex == -1 ) {
        selected = 0;
    }
    return [self.channel numberOfProgramsInDay:selected];
}

- (void)setScheduledIcon:(UIImageView*)schedStatusIcon forEpg:(TVHEpg*)epg {
    factory.size = 12;
    factory.colors = @[[UIColor grayColor], [UIColor lightGrayColor]];
    [schedStatusIcon setImage:nil];
    if ( [epg isScheduledForRecording] ) {
        [schedStatusIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconTime]];
    }
    if ( [epg isRecording] ) {
        factory.colors = @[[UIColor redColor]];
        [schedStatusIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconBullseye]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgramListTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TVHEpg *epg = [self.channel programDetailForDay:self.segmentedControl.selectedSegmentIndex index:indexPath.row];
    
    UILabel *name = (UILabel *)[cell viewWithTag:100];
	UILabel *description = (UILabel *)[cell viewWithTag:101];
    UILabel *hour = (UILabel *)[cell viewWithTag:102];
    UIImageView *schedStatusImage = (UIImageView *)[cell viewWithTag:104];
    TVHProgressBar *progress = (TVHProgressBar *)[cell viewWithTag:105];
    
    hour.text = [timeFormatter stringFromDate: epg.start];
    name.text = epg.fullTitle;
    description.text = epg.description;
    if( [description.text isEqualToString:@""] ) {
        description.text = NSLocalizedString(@"Not Available", nil);;
    }
    [progress setHidden:YES];
    
    if( epg == self.channel.currentPlayingProgram ) {
        CGRect progressBarFrame = {
            .origin.x = progress.frame.origin.x,
            .origin.y = progress.frame.origin.y,
            .size.width = progress.frame.size.width,
            .size.height = 4,
        };
        [progress setFrame:progressBarFrame];
        progress.progress = epg.progress;
        progress.hidden = NO;
        
        if ( epg.progress < 0.9 ) {
            [progress setTintColor:[UIColor colorWithRed:0.3 green:0.6 blue:0.9 alpha:1]];
        } else {
            [progress setTintColor:[UIColor colorWithRed:0.0 green:0.3 blue:0.5 alpha:1]];
        }
    } 
    
    [self setScheduledIcon:schedStatusImage forEpg:epg];
    
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", epg.fullTitle, [timeFormatter stringFromDate: epg.start]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *sepColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 1)];
    [sepColor setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [cell.contentView addSubview:sepColor];
    
    //UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    //[cell.contentView addSubview: separator];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Program Detail"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHEpg *epg = [self.channel programDetailForDay:self.segmentedControl.selectedSegmentIndex index:path.row];
        
        TVHProgramDetailViewController *programDetail = segue.destinationViewController;
        [programDetail setChannel:self.channel];
        [programDetail setEpg:epg];
        [programDetail setTitle:epg.title];
    }
}

- (void)willLoadEpgChannel {
    if ( ! [self.refreshControl isRefreshing] ) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    }
}

- (void)didLoadEpgChannel {
    [self updateSegmentControl];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didErrorLoadingEpgChannel:(NSError*) error {
    [TVHShowNotice errorNoticeInView:self.view title:NSLocalizedString(@"Network Error",nil) message:error.localizedDescription];
    [self.refreshControl endRefreshing];
}

- (IBAction)playStream:(UIBarButtonItem*)sender {
    if(!self.help) {
        self.help = [[TVHPlayStreamHelpController alloc] init];
    }
    
    [self.help playStream:sender withChannel:self.channel withVC:self];
}

- (IBAction)segmentDidChange:(id)sender {
    [self.tableView reloadData];
}


@end
