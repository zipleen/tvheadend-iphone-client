//
//  TVHTagListViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHTagStoreViewController.h"
#import "TVHChannelStoreViewController.h"

@interface TVHTagStoreViewController ()
@property (strong, nonatomic) TVHTagStore *tagList;
@end

@implementation TVHTagStoreViewController
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)didErrorLoading {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@"Error connecting to server - this should redirect you to settings app"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    [errorAlert show];
}

@end
