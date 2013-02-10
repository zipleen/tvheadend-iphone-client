//
//  TVHChannelListProgramsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannelListProgramsViewController.h"
#import "TVHEpg.h"

@interface TVHChannelListProgramsViewController ()
@property (nonatomic, strong) NSArray *programList;
@end

@implementation TVHChannelListProgramsViewController
@synthesize channel = _channel;

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
    self.programList = [self.channel getEpg];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.programList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgramListTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    TVHEpg *epg = [self.programList objectAtIndex:indexPath.row];
    cell.textLabel.text = epg.title;
    cell.detailTextLabel.text = epg.description;
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Channel Detail"]) {
        
        /*NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHTag *tag = [self.tagList objectAtIndex:path.row];
        
        TVHChannelListViewController *ChannelList = segue.destinationViewController;
        [ChannelList setFilterTagId: tag.tagid];
        
        [segue.destinationViewController setTitle:tag.name];*/
    }
}

@end
