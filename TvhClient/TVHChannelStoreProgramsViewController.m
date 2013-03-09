//
//  TVHChannelListProgramsViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannelStoreProgramsViewController.h"
#import "TVHProgramDetailViewController.h"
#import "TVHEpg.h"
#import "WBErrorNoticeView.h"
#import "CKRefreshControl.h"
#import "TVHPlayStreamHelpController.h"

@interface TVHChannelStoreProgramsViewController () <TVHChannelDelegate, UIActionSheetDelegate> {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
}
@property (strong, nonatomic) TVHPlayStreamHelpController *help;
@end

@implementation TVHChannelStoreProgramsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.channel setDelegate:self];
    [self.channel downloadRestOfEpg];
    
    //pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.channel = nil;
    dateFormatter = nil;
    timeFormatter = nil;
    self.help = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pullToRefreshViewShouldRefresh
{
    [self.channel resetChannelEpgStore];
    [self.tableView reloadData];
    [self.channel downloadRestOfEpg];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.channel totalCountOfDaysEpg];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    NSDate *date = [self.channel dateForDay:section];
    return [dateFormatter stringFromDate:date];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channel numberOfProgramsInDay:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgramListTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    TVHEpg *epg = [self.channel programDetailForDay:indexPath.section index:indexPath.row];
    
    UILabel *name = (UILabel *)[cell viewWithTag:100];
	UILabel *description = (UILabel *)[cell viewWithTag:101];
    UILabel *hour = (UILabel *)[cell viewWithTag:102];
    UIProgressView *progress = (UIProgressView *)[cell viewWithTag:103];
    
    hour.text = [timeFormatter stringFromDate: epg.start];
    name.text = epg.title;
    description.text = epg.description;
    
    if( epg == self.channel.currentPlayingProgram ) {
        description.text = nil;
        progress.progress = epg.progress;
        progress.hidden = NO;
    } else {
        progress.hidden = YES;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    [cell.contentView addSubview: separator];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Show Program Detail"]) {
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        TVHEpg *epg = [self.channel programDetailForDay:path.section index:path.row];
        
        TVHProgramDetailViewController *programDetail = segue.destinationViewController;
        [programDetail setChannel:self.channel];
        [programDetail setEpg:epg];
        [programDetail setTitle:self.channel.name];
        
    }
}

- (void)didLoadEpgChannel {
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)didErrorLoadingEpgChannel:(NSError*) error {
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:NSLocalizedString(@"Network Error",nil) message:error.localizedDescription];
    [notice setSticky:true];
    [notice show];
    [self.refreshControl endRefreshing];
}

- (IBAction)playStream:(UIBarButtonItem*)sender {
    if(!self.help) {
        self.help = [[TVHPlayStreamHelpController alloc] init];
    }
    
    [self.help playStream:sender withChannel:self.channel withVC:self];
}

@end
