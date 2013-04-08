//
//  TVHEpgTableViewController.m
//  TvhClient
//
//  Created by zipleen on 3/10/13.
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

#import "TVHEpgTableViewController.h"
#import "TVHProgramDetailViewController.h"
#import "TVHEpgStore.h"
#import "TVHChannelStore.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface TVHEpgTableViewController () <TVHEpgStoreDelegate, UISearchBarDelegate> {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *hourFormatter;
}
@property (nonatomic, strong) TVHEpgStore *epgStore;
@property (nonatomic, strong) NSArray *epgTable ;
@end

@implementation TVHEpgTableViewController {
    BOOL shouldBeginEditing;
}

- (TVHEpgStore*)epgStore {
    if ( !_epgStore ) {
        // we need a DIFFERENT epgstore, because of the delegate
        // should we change this to a notification? this epgstore SHOULD be shared!!
        _epgStore = [[TVHEpgStore alloc] init];
    }
    return _epgStore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.epgStore setDelegate:self];
    
    // I shouldn't have this here, it should be smart to know it needs channels!
    TVHChannelStore *channelStore = [TVHChannelStore sharedInstance];
    if ( [[channelStore getFilteredChannelList] count] == 0 ) {
        [channelStore fetchChannelList];
    }
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E d MMM, HH:mm"];
    
    hourFormatter = [[NSDateFormatter alloc] init];
    hourFormatter.dateFormat = @"HH:mm";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetEpgStore)
                                                 name:@"resetAllObjects"
                                               object:nil];
    self.searchBar.delegate = self;
    shouldBeginEditing = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    if ( [self.epgTable count] == 0 ) {
        [self.epgStore downloadEpgList];
    }
#ifdef TVH_GOOGLEANALYTICS_KEY
        [[GAI sharedInstance].defaultTracker sendView:NSStringFromClass([self class])];
#endif
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.epgStore = nil;
    self.epgTable = nil;
}

- (void)resetEpgStore {
    self.epgTable = nil;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.epgTable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EpgTableCellItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TVHEpg *epg = [self.epgTable objectAtIndex:indexPath.row];
    
    UILabel *programLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:101];
    UIImageView *channelImage = (UIImageView *)[cell viewWithTag:102];
    UIProgressView *currentTimeProgress = (UIProgressView*)[cell viewWithTag:103];
	programLabel.text = nil;
    timeLabel.text = nil;
    currentTimeProgress.hidden = YES;
    
    programLabel.text = epg.fullTitle;
    timeLabel.text = [NSString stringWithFormat:@"%@ - %@ (%d min)", [dateFormatter stringFromDate:epg.start], [hourFormatter stringFromDate:epg.end], epg.duration/60 ];
    
    [channelImage setImageWithURL:[NSURL URLWithString:epg.chicon] placeholderImage:[UIImage imageNamed:@"tv2.png"]];
    
    // rouding corners - this makes the animation in ipad become VERY SLOW!!!
    //channelImage.layer.cornerRadius = 5.0f;
    channelImage.layer.masksToBounds = NO;
    channelImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    channelImage.layer.borderWidth = 0.4;
    channelImage.layer.shouldRasterize = YES;
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    [cell.contentView addSubview: separator];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == [self.epgTable count] - 1 ) {
        [self.epgStore downloadEpgList];
    }
}

- (void)didLoadEpg:(TVHEpgStore*)epgStore {
    [self.refreshControl endRefreshing];
    self.epgTable = [epgStore epgStoreItems];
    [self.tableView reloadData];
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.epgStore downloadEpgList];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Program Detail from EPG"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHEpg *epg = [self.epgTable objectAtIndex:path.row];
        
        TVHProgramDetailViewController *programDetail = segue.destinationViewController;
        [programDetail setChannel:[epg channelObject]];
        [programDetail setEpg:epg];
        [programDetail setTitle:epg.title];
    }
}

#pragma mark - search bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( ![searchBar isFirstResponder] ) {
        shouldBeginEditing = NO;
        [self.epgStore setFilterToProgramTitle:@""];
        [self.epgStore downloadEpgList];
    }
    [self.epgStore setFilterToProgramTitle:searchBar.text];
    [self.epgStore downloadEpgList];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
