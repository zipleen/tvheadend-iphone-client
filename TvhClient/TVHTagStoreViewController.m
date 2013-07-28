//
//  TVHTagListViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHTagStoreViewController.h"
#import "TVHChannelStoreViewController.h"
#import "CKRefreshControl.h"
#import "UIImageView+WebCache.h"
#import "TVHShowNotice.h"
#import "TVHImageCache.h"
#import "TVHEpgTableViewController.h"
#import "TVHSingletonServer.h"

@interface TVHTagStoreViewController ()
@property (weak, nonatomic) TVHTagStore *tagStore;
@property (strong, nonatomic) NSArray *tags;
@end

@implementation TVHTagStoreViewController

- (TVHTagStore*)tagStore {
    if ( _tagStore == nil) {
        _tagStore = [[TVHSingletonServer sharedServerInstance] tagStore];
    }
    return _tagStore;
}

- (void)resetControllerData {
    self.tags = nil;
    [self.tagStore setDelegate:self];
    [self.tagStore fetchTagList];
}

- (void)viewWillAppear:(BOOL)animated {
    if ( self.splitViewController ) {
        UINavigationController *detailView = [self.splitViewController.viewControllers lastObject];
        [detailView popToRootViewControllerAnimated:YES];
    }
    [self prepareSplitViewEpg:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker sendView:NSStringFromClass([self class])];
#endif
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                                    self.tableView);
}

- (void)initDelegate {
    if( [self.tagStore delegate] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLoadTags)
                                                     name:@"didLoadTags"
                                                   object:self.tagStore];
    } else {
        [self.tagStore setDelegate:self];
    }
 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initDelegate];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    
    TVHSettings *settings = [TVHSettings sharedInstance];
    if( [settings selectedServer] == NSNotFound ) {
        [self performSegueWithIdentifier:@"ShowSettings" sender:self];
    } 
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetControllerData)
                                                 name:@"resetAllObjects"
                                               object:nil];
    self.settingsButton.title = NSLocalizedString(@"Settings", @"");
}

- (void)viewDidUnload {
    self.tagStore = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSettingsButton:nil];
    [super viewDidUnload];
}

- (void)pullToRefreshViewShouldRefresh {
    [self.tagStore fetchTagList];
}

- (void)reloadData {
    self.tags = [[self.tagStore tags] copy];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagListTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TVHTag *tag = [self.tags objectAtIndex:indexPath.row];
    
    UILabel *tagNameLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *tagNumberLabel = (UILabel *)[cell viewWithTag:101];
	__weak UIImageView *channelImage = (UIImageView *)[cell viewWithTag:102];
    tagNameLabel.text = tag.name;
    tagNumberLabel.text = nil;
    channelImage.contentMode = UIViewContentModeScaleAspectFit;
    [channelImage setImageWithURL:[NSURL URLWithString:tag.icon] placeholderImage:[UIImage imageNamed:@"tag.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (!error) {
            channelImage.image = [TVHImageCache resizeImage:image];
        }
    } ];
    
    cell.accessibilityLabel = tag.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *sepColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 1)];
    [sepColor setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [cell.contentView addSubview:sepColor];

    //UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"] ];
    //[cell.contentView addSubview: separator];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Channel List"]) {
        TVHChannelStoreViewController *channelStore = segue.destinationViewController;
        [self prepareChannelStoreView:channelStore];
    }
}

- (void)prepareChannelStoreView:(TVHChannelStoreViewController*)channelStore {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    TVHTag *tag = [self.tags objectAtIndex:path.row];
    
    [channelStore setFilterTagId:tag.id];
    [channelStore setTitle:tag.name];
    
    [self prepareSplitViewEpg:tag];
}

- (void)prepareSplitViewEpg:(TVHTag*)tag {
    if ( self.splitViewController ) {
        UINavigationController *detailView = [self.splitViewController.viewControllers lastObject];
        [detailView popToRootViewControllerAnimated:YES];
        TVHEpgTableViewController *epgDetailView = [detailView.viewControllers lastObject];
        [epgDetailView setFilterTag:tag.name];
        if ( tag ) {
            [epgDetailView setTitle:[@[NSLocalizedString(@"Now in", nil), tag.name] componentsJoinedByString:@" "]];
        } else {
            [epgDetailView setTitle:NSLocalizedString(@"Now", nil)];
        }
    }
}

- (void)willLoadTags {
    if ( ! [self.refreshControl isRefreshing] ) {
        [self.refreshControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    }
}

- (void)didLoadTags {
    [self reloadData];
    [self.refreshControl endRefreshing];
    if ( [self.tags count] == 1 ) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self performSegueWithIdentifier:@"Show Channel List" sender:self];
    }
}

- (void)didErrorLoadingTagStore:(NSError*) error {
    [TVHShowNotice errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.localizedDescription];
    [self reloadData];
    [self.refreshControl endRefreshing];
}


@end
