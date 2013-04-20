//
//  TVHChannelListProgramsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHChannelStoreProgramsViewController.h"
#import "TVHProgramDetailViewController.h"
#import "TVHEpg.h"
#import "TVHShowNotice.h"
#import "CKRefreshControl.h"
#import "TVHPlayStreamHelpController.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface TVHChannelStoreProgramsViewController () <TVHChannelDelegate, UIActionSheetDelegate> {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.channel setDelegate:self];
    [self.channel downloadRestOfEpg];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE"];
    timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    factory.size = 16;
    [self.navigationItem.rightBarButtonItem setImage:[factory createImageForIcon:NIKFontAwesomeIconFilm]];
    [self.navigationItem.rightBarButtonItem setAccessibilityLabel:NSLocalizedString(@"Play Channel", @"accessbility")];
    
    [self.segmentedControl removeAllSegments];
    [self updateSegmentControl];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

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
    UIProgressView *progress = (UIProgressView *)[cell viewWithTag:103];
    
    hour.text = [timeFormatter stringFromDate: epg.start];
    name.text = epg.fullTitle;
    description.text = epg.description;
    
    if( epg == self.channel.currentPlayingProgram ) {
        description.text = nil;
        progress.progress = epg.progress;
        progress.hidden = NO;
        
    } else {
        progress.hidden = YES;
    }
    
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", epg.fullTitle, [timeFormatter stringFromDate: epg.start]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    [cell.contentView addSubview: separator];
    
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
