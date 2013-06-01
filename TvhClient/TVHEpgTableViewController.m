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
#import "TVHImageCache.h"
#import "TVHSingletonServer.h"
#import "TVHShowNotice.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface TVHEpgTableViewController () <TVHEpgStoreDelegate, UISearchBarDelegate> {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *hourFormatter;
    NIKFontAwesomeIconFactory *factory;
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
        _epgStore = [[TVHEpgStore alloc] initWithTvhServer:[TVHSingletonServer sharedServerInstance]];
        [self.epgStore setDelegate:self];
    }
    return _epgStore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E d MMM, HH:mm"];
    
    hourFormatter = [[NSDateFormatter alloc] init];
    hourFormatter.dateFormat = @"HH:mm";
    
    factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    factory.size = 16;
    factory.colors = @[[UIColor grayColor], [UIColor lightGrayColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetEpgStore)
                                                 name:@"resetAllObjects"
                                               object:nil];
    self.searchBar.delegate = self;
    shouldBeginEditing = YES;
    self.title = NSLocalizedString(@"Now", @"");
    self.searchBar.placeholder = NSLocalizedString(@"Search Program Title", @"");
    
    [self.epgStore downloadEpgList];
}

- (void)viewDidAppear:(BOOL)animated {
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
    self.epgStore = nil;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.epgTable count];
}

- (void)setScheduledIcon:(UIImageView*)schedStatusIcon forEpg:(TVHEpg*)epg {
    factory.colors = @[[UIColor grayColor], [UIColor lightGrayColor]];
    [schedStatusIcon setImage:nil];
    if ( [[epg schedstate] isEqualToString:@"scheduled"] ) {
        [schedStatusIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconTime]];
    }
    if ( [[epg schedstate] isEqualToString:@"recording"] ) {
        factory.colors = @[[UIColor redColor]];
        [schedStatusIcon setImage:[factory createImageForIcon:NIKFontAwesomeIconBullseye]];
    }
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
    __weak UIImageView *channelImage = (UIImageView *)[cell viewWithTag:102];
    UILabel *channelName = (UILabel *)[cell viewWithTag:103];
    UIImageView *schedStatusImage = (UIImageView *)[cell viewWithTag:104];
    
    programLabel.text = epg.fullTitle;
    timeLabel.text = [NSString stringWithFormat:@"%@ - %@ (%d min)", [dateFormatter stringFromDate:epg.start], [hourFormatter stringFromDate:epg.end], epg.duration/60 ];
    channelName.text = epg.channel;
    channelImage.contentMode = UIViewContentModeScaleAspectFit;
    [channelImage setImageWithURL:[NSURL URLWithString:epg.chicon] placeholderImage:[UIImage imageNamed:@"tv2.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (!error) {
            channelImage.image = [TVHImageCache resizeImage:image];
        }
    } ];
    
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
    
    [self setScheduledIcon:schedStatusImage forEpg:epg];
    
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@", epg.fullTitle, NSLocalizedString(@"in",@"accessibility"), epg.channel,NSLocalizedString(@"starts at",@"accessibility"),[dateFormatter stringFromDate:epg.start], NSLocalizedString(@"finishes at",@"accessibility"),[dateFormatter stringFromDate:epg.end] ];
    
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
        [self.epgStore downloadMoreEpgList];
    }
}

- (void)reloadData:(TVHEpgStore*)epgStore {
    [self.refreshControl endRefreshing];
    self.epgTable = [epgStore epgStoreItems];
    [self.tableView reloadData];
}

- (void)didLoadEpg:(TVHEpgStore*)epgStore {
    [self.refreshControl endRefreshing];
    self.epgTable = [[epgStore epgStoreItems] copy];
    [self.tableView reloadData];
}

- (void)didErrorLoadingEpgStore:(NSError *)error {
    [TVHShowNotice errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.localizedDescription];
    [self.refreshControl endRefreshing];
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.epgStore downloadMoreEpgList];
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
        [self setFilterProgramTitle:@""];
        return;
    }
    
    [self setFilterProgramTitle:searchBar.text];
    if ( [searchText isEqualToString:@""] ) {
        // why do I have to do this!??! if I put the resignFirstResponder here, it doesn't work...
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
    }
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
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

#pragma mark - epg filter

- (void)setFilterProgramTitle:(NSString*)programTitle {
    [self.epgStore setFilterToProgramTitle:programTitle];
    [self.epgStore downloadEpgList];
}

- (void)setFilterTag:(NSString *)tag {
    [self.epgStore setFilterToTagName:tag];
    [self.epgStore downloadEpgList];
}

@end
