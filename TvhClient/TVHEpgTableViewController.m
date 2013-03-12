//
//  TVHEpgTableViewController.m
//  TvhClient
//
//  Created by zipleen on 3/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpgTableViewController.h"
#import "TVHProgramDetailViewController.h"
#import "TVHEpgStore.h"
#import "TVHChannelStore.h"

@interface TVHEpgTableViewController () <TVHEpgStoreDelegate>
@property (nonatomic, strong) TVHEpgStore *epgStore;
@property (nonatomic, strong) NSArray *epgTable ;
@end

@implementation TVHEpgTableViewController 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // we need a DIFFERENT epgstore, because of the delegate
    // should we change this to a notification? this epgstore SHOULD be shared!!
    self.epgStore = [[TVHEpgStore alloc] init];
    [self.epgStore setDelegate:self];
    [self.epgStore downloadEpgList];
    
    TVHChannelStore *channelStore = [TVHChannelStore sharedInstance];
    if ( [[channelStore getFilteredChannelList] count] == 0 ) {
        [channelStore fetchChannelList];
    }
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidUnload
{
    self.epgStore = nil;
    self.epgTable = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    TVHEpg *epg = [self.epgTable objectAtIndex:indexPath.row];
    cell.textLabel.text = epg.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", epg.start];
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    [cell.contentView addSubview: separator];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)didLoadEpg:(TVHEpgStore*)epgStore {
    self.epgTable = [epgStore getEpgList];
    [self.refreshControl endRefreshing];
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

@end
