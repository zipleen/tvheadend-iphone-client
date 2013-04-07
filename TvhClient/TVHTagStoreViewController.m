//
//  TVHTagListViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
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

#import "TVHTagStoreViewController.h"
#import "TVHChannelStoreViewController.h"
#import "CKRefreshControl.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TVHChannelStore.h"
#import "TVHSettings.h"
#import "TVHShowNotice.h"

#import "TVHStatusSubscriptionsStore.h"
#import "TVHAdaptersStore.h"
#import "TVHLogStore.h"
#import "TVHCometPollStore.h"

@interface TVHTagStoreViewController ()
@property (strong, nonatomic) TVHTagStore *tagList;
@end

@implementation TVHTagStoreViewController

- (TVHTagStore*) tagList {
    if ( _tagList == nil) {
        _tagList = [TVHTagStore sharedInstance];
    }
    return _tagList;
}

- (void)resetControllerData {
    [self.tagList fetchTagList];
    [[TVHChannelStore sharedInstance] fetchChannelList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tagList setDelegate:self];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    
    TVHSettings *settings = [TVHSettings sharedInstance];
    if( [settings selectedServer] == NSNotFound ) {
        [self performSegueWithIdentifier:@"ShowSettings" sender:self];
    } else {
        // fetch tags
        [self.tagList fetchTagList];
        
        // and fetch channel data - we need it for a lot of things, channels should always be loaded!
        [[TVHChannelStore sharedInstance] fetchChannelList];
        
        // and maybe start comet poll - after initing status and log
        [TVHStatusSubscriptionsStore sharedInstance];
        [TVHAdaptersStore sharedInstance];
        [TVHLogStore sharedInstance];
        [TVHCometPollStore sharedInstance];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetControllerData)
                                                 name:@"resetAllObjects"
                                               object:nil];
}

- (void)viewDidUnload {
    self.tagList = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.tagList fetchTagList];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tagList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TagListTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TVHTag *tag = [self.tagList objectAtIndex:indexPath.row];
    
    UILabel *tagNameLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *tagNumberLabel = (UILabel *)[cell viewWithTag:101];
	UIImageView *channelImage = (UIImageView *)[cell viewWithTag:102];
    tagNameLabel.text = tag.name;
    tagNumberLabel.text = nil;
    [channelImage setImageWithURL:[NSURL URLWithString:tag.icon] placeholderImage:[UIImage imageNamed:@"tag.png"]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"] ];
    [cell.contentView addSubview: separator];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Channel List"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHTag *tag = [self.tagList objectAtIndex:path.row];
        
        TVHChannelStoreViewController *ChannelList = segue.destinationViewController;
        [ChannelList setFilterTagId: tag.id];
        
        [segue.destinationViewController setTitle:tag.name];
    }
}

- (void)didLoadTags {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didErrorLoadingTagStore:(NSError*) error {
    [TVHShowNotice errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", nil) message:error.localizedDescription];
    
    [self.refreshControl endRefreshing];
}


@end
