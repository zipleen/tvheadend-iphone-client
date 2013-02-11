//
//  TVHChannelListProgramsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannelListProgramsViewController.h"
#import "TVHProgramDetailViewController.h"
#import "TVHEpg.h"

@interface TVHChannelListProgramsViewController () <TVHChannelDelegate>
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
    [self.channel setDelegate:self];
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
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    cell.textLabel.text = [timeFormatter stringFromDate: epg.start];
    
    cell.detailTextLabel.text = epg.title;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Program Detail"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHEpg *epg = [self.programList objectAtIndex:path.row];
        
        TVHProgramDetailViewController *programDetail = segue.destinationViewController;
        [programDetail setChannel:self.channel];
        [programDetail setEpg:epg];
        
    }
}

- (void)didLoadEpgChannel {
    [self.tableView reloadData];
}

@end
