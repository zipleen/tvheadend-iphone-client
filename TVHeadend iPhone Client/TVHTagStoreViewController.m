//
//  TVHTagListViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHTagStoreViewController.h"
#import "TVHChannelStoreViewController.h"
#import "WBErrorNoticeView.h"
#import "PullToRefreshView.h"

@interface TVHTagStoreViewController () <PullToRefreshViewDelegate>
@property (strong, nonatomic) TVHTagStore *tagList;
@end

@implementation TVHTagStoreViewController{
    PullToRefreshView *pull;
}
@synthesize tagList = _tagList;

- (TVHTagStore*) tagList {
    if ( _tagList == nil) {
        _tagList = [TVHTagStore sharedInstance];
    }
    return _tagList;
}

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

    [self.tagList setDelegate:self];
    [self.tagList fetchTagList];
    
    //pull to refresh
    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self.tagList resetTagStore];
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
    
    // Configure the cell...
    TVHTag *tag = [self.tagList objectAtIndex:indexPath.row];
    cell.textLabel.text = tag.name;
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:tag.imageUrl] placeholderImage:[UIImage imageNamed:@"tag.png"]];
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Channel List"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHTag *tag = [self.tagList objectAtIndex:path.row];
        
        TVHChannelStoreViewController *ChannelList = segue.destinationViewController;
        [ChannelList setFilterTagId: tag.tagid];
        
        [segue.destinationViewController setTitle:tag.name];
    }
}

- (void)didLoadTags {
    [self.tableView reloadData];
    [pull finishedLoading];
}

- (void)didErrorLoadingTagStore:(NSError*) error {
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Network Error" message:error.description];
    [notice setSticky:true];
    [notice show];
}


@end
