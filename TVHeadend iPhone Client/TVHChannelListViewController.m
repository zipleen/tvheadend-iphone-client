//
//  tvhclientChannelListViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/2/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannelListViewController.h"
#import "TVHChannelListProgramsViewController.h"
#import "TVHChannel.h"

@interface TVHChannelListViewController ()
@property (strong, nonatomic) TVHChannelList *channelList;
@end

@implementation TVHChannelListViewController
@synthesize channelList = _channelList;
@synthesize filterTagId = _filterTagId;

- (NSInteger) filterTagId {
    if(!_filterTagId) {
        return 0;
    }
    return _filterTagId;
}

- (TVHChannelList*) channelList {
    if ( _channelList == nil) {
        _channelList = [TVHChannelList sharedInstance];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.channelList setDelegate:self];
    [self.channelList setFilterTag: self.filterTagId];
    [self.channelList fetchChannelList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // Configure the cell...
    TVHChannel *ch = [self.channelList objectAtIndex:indexPath.row];
    cell.textLabel.text = ch.name;
    cell.detailTextLabel.text = [ch getCurrentPlayingProgram];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:ch.imageUrl] placeholderImage:[UIImage imageNamed:@"tv.png"]];
    
    cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    
    if( [ch countEpg] > 0 ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Channel Programs"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHChannel *channel = [self.channelList objectAtIndex:path.row];
        
        TVHChannelListProgramsViewController *channelPrograms = segue.destinationViewController;
        [channelPrograms setChannel:channel];
        
        [segue.destinationViewController setTitle:channel.name];
    }
}

- (void)didLoadChannels {
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
