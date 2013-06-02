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
#import "TVHSettingsGenericFieldViewController.h"

@interface TVHEpgTableViewController () <TVHEpgStoreDelegate, UISearchBarDelegate> {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *hourFormatter;
    NIKFontAwesomeIconFactory *factory;
}
@property (nonatomic, strong) TVHEpgStore *epgStore;
@property (nonatomic, strong) NSArray *epgTable ;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
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
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
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
    [self.searchBar setDelegate:self];
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
    [self setFilterToolBar:nil];
    [self setFilterSegmentedControl:nil];
    [self setSearchBar:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.epgStore = nil;
    self.epgTable = nil;
    self.tableView = nil;
}

- (void)resetEpgStore {
    self.epgTable = nil;
    self.epgStore = nil;
    [self.tableView reloadData];
    [self.epgStore downloadEpgList];
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
    
    if([segue.identifier isEqualToString:@"Select Filter Pref"]) {
        TVHSettingsGenericFieldViewController *vc = segue.destinationViewController;
        int clickedFilterButton = [self.filterSegmentedControl selectedSegmentIndex];
        if ( clickedFilterButton == 0 ) {
            TVHChannelStore *channelStore = [[TVHSingletonServer sharedServerInstance] channelStore];
            NSArray *objectChannelList = [channelStore channels];
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [objectChannelList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [list addObject:[obj name]];
            }];
            
            [vc setTitle:NSLocalizedString(@"Channel", nil)];
            [vc setSectionHeader:NSLocalizedString(@"Channel", nil)];
            [vc setOptions:list];
            [vc setSelectedOption:[list indexOfObject:[self.filterSegmentedControl titleForSegmentAtIndex:0]]];
            [vc setResponseBack:^(NSInteger order) {
                NSString *text = [list objectAtIndex:order];
                [self setFilterChannelName:text];
            }];


        }
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

- (void)setFilterChannelName:(NSString*)channelName{
    if( channelName ) {
        [self.filterSegmentedControl setTitle:channelName forSegmentAtIndex:0];
    } else {
        [self.filterSegmentedControl setTitle:NSLocalizedString(@"Channel", nil) forSegmentAtIndex:0];
    }
    [self.epgStore setFilterToChannelName:channelName];
    [self.epgStore downloadEpgList];
}

- (void)setFilterTag:(NSString *)tag {
    if( tag ) {
        [self.filterSegmentedControl setTitle:tag forSegmentAtIndex:1];
    } else {
        [self.filterSegmentedControl setTitle:NSLocalizedString(@"Tag", nil) forSegmentAtIndex:1];
    }
    [self.epgStore setFilterToTagName:tag];
    [self.epgStore downloadEpgList];
}

- (void)setFilterContentType:(NSString *)contentType {
    if( contentType ) {
        [self.filterSegmentedControl setTitle:contentType forSegmentAtIndex:2];
    } else {
        [self.filterSegmentedControl setTitle:NSLocalizedString(@"Content Type", nil) forSegmentAtIndex:2];
    }
    [self.epgStore setFilterToContentTypeId:contentType];
    [self.epgStore downloadEpgList];
}

- (IBAction)filterSegmentedControlClicked:(UISegmentedControl *)sender {
    [self performSegueWithIdentifier:@"Select Filter Pref" sender:self];
}

- (IBAction)showHideSegmentedBar:(UIBarButtonItem *)sender {
    if ( self.filterToolBar.hidden ) {
        self.filterToolBar.hidden = NO;
        [UIView animateWithDuration:.5
                         animations:^(void) {
                             CGRect toolbarFrame = self.filterToolBar.frame;
                             toolbarFrame.origin.y = 0;
                             self.filterToolBar.frame = toolbarFrame;
                             
                             CGRect tableFrame = self.tableView.frame;
                             tableFrame.origin.y = 44;
                             tableFrame.size.height = self.view.frame.size.height;
                             self.tableView.frame = tableFrame;
                         }
                         completion:^(BOOL finished) {
                         }
         ];
    } else {
        [UIView animateWithDuration:.5
                         animations:^(void) {
                             CGRect toolbarFrame = self.filterToolBar.frame;
                             toolbarFrame.origin.y = -44; 
                             self.filterToolBar.frame = toolbarFrame;
                             
                             CGRect tableFrame = self.tableView.frame;
                             tableFrame.origin.y = 0;
                             tableFrame.size.height = self.view.frame.size.height;
                             self.tableView.frame = tableFrame;
                         }
                         completion:^(BOOL finished) {
                            self.filterToolBar.hidden = YES;
                        }
         ];
    }
}

@end
