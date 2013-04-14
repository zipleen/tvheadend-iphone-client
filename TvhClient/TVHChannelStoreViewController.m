//
//  tvhclientChannelListViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/2/13.
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

#import "TVHChannelStoreViewController.h"
#import "TVHChannelStoreProgramsViewController.h"
#import "TVHChannel.h"
#import "TVHShowNotice.h"
#import "CKRefreshControl.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

@interface TVHChannelStoreViewController () {
    NSDateFormatter *dateFormatter;
}
@property (strong, nonatomic) TVHChannelStore *channelList;
@end

@implementation TVHChannelStoreViewController

// if we're called from tagstore, we'll set the filter of the channelStore to only get channels from the selected tag
- (NSInteger) filterTagId {
    if(!_filterTagId) {
        return 0;
    }
    return _filterTagId;
}

- (TVHChannelStore*) channelList {
    if ( _channelList == nil) {
        _channelList = [TVHChannelStore sharedInstance];
    }
    return _channelList;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker sendView:NSStringFromClass([self class])];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setTitle:NSLocalizedString(@"Channels", nil)];
    
    [self.channelList setDelegate:self];
    [self.channelList setFilterTag: self.filterTagId];
    [self.channelList fetchChannelList];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
}

- (void)viewDidUnload {
    self.channelList = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.channelList fetchChannelList];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channelList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChannelListTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TVHChannel *ch = [self.channelList objectAtIndex:indexPath.row];
    TVHEpg *currentPlayingProgram = [ch currentPlayingProgram];
    
    UILabel *channelNameLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *currentProgramLabel = (UILabel *)[cell viewWithTag:101];
	UIImageView *channelImage = (UIImageView *)[cell viewWithTag:102];
    UILabel *currentTimeProgramLabel = (UILabel *)[cell viewWithTag:103];
    UIProgressView *currentTimeProgress = (UIProgressView*)[cell viewWithTag:104];
    
	currentProgramLabel.text = nil;
    currentTimeProgramLabel.text = nil;
    currentTimeProgress.hidden = true;
    
    channelNameLabel.text = ch.name;
    [channelImage setImageWithURL:[NSURL URLWithString:ch.imageUrl] placeholderImage:[UIImage imageNamed:@"tv2.png"]];
    
    
    // rouding corners - this makes the animation in ipad become VERY SLOW!!!
    //channelImage.layer.cornerRadius = 5.0f;
    channelImage.layer.masksToBounds = NO;
    channelImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    channelImage.layer.borderWidth = 0.4;
    channelImage.layer.shouldRasterize = YES;
        
    if(currentPlayingProgram) {
        currentProgramLabel.text = [currentPlayingProgram fullTitle];
        currentTimeProgramLabel.text = [NSString stringWithFormat:@"%@ | %@", [dateFormatter stringFromDate:currentPlayingProgram.start], [dateFormatter stringFromDate:currentPlayingProgram.end]];
        currentTimeProgress.hidden = false;
        currentTimeProgress.progress = [currentPlayingProgram progress];
        cell.accessibilityLabel = ch.name;
        cell.accessibilityHint = [NSString stringWithFormat:@"%@ %@ %@ %@", NSLocalizedString(@"currently playing",@"accessibility"), currentPlayingProgram.title, NSLocalizedString(@"finishes at",@"accessibility"),[dateFormatter stringFromDate:currentPlayingProgram.end] ];
    } else {
        cell.accessibilityLabel = ch.name;
    }
     
    UIImageView *separator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"separator.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    [cell.contentView addSubview: separator];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Show Channel Programs" sender:self]; 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Channel Programs"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHChannel *channel = [self.channelList objectAtIndex:path.row];
        
        TVHChannelStoreProgramsViewController *channelPrograms = segue.destinationViewController;
        [channelPrograms setChannel:channel];
        
        [segue.destinationViewController setTitle:channel.name];
    }
}

- (void)didLoadChannels {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didErrorLoadingChannelStore:(NSError*) error {
    [TVHShowNotice errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.localizedDescription];
    
    [self.refreshControl endRefreshing];
}

@end
