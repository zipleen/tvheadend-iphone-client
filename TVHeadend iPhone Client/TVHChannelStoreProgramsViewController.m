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

@interface TVHChannelStoreProgramsViewController () <TVHChannelDelegate, UIActionSheetDelegate>

@end

@implementation TVHChannelStoreProgramsViewController


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
    [self.channel downloadRestOfEpg];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.channel totalCountOfDaysEpg];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [self.channel dateStringForDay:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.channel numberOfProgramsInDay:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgramListTableItems";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    TVHEpg *epg = [self.channel programDetailForDay:indexPath.section index:indexPath.row];
    
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
        TVHEpg *epg = [self.channel programDetailForDay:path.section index:path.row];
        
        TVHProgramDetailViewController *programDetail = segue.destinationViewController;
        [programDetail setChannel:self.channel];
        [programDetail setEpg:epg];
        
    }
}

- (void)didLoadEpgChannel {
    [self.tableView reloadData];
}

- (void)didErrorLoadingEpgChannel:(NSError*) error {
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Network Error" message:error.description];
    [notice setSticky:true];
    [notice show];
}

- (IBAction)playStream:(UIBarButtonItem*)sender {
    NSString *actionSheetTitle = @"Copy to Clipboard"; //Action Sheet Title
    NSString *other1 = @"Buzz Player";
    NSString *other2 = @"GoodPlayer";
    NSString *other3 = @"Oplayer";
    NSString *cancelTitle = @"Cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:actionSheetTitle, other1, other2, other3, nil];
    //[actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet showFromBarButtonItem:sender  animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Copy to Clipboard"]) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:[self.channel streamURL]];
    }
    if ([buttonTitle isEqualToString:@"Buzz Player"]) {
        NSString *url = [NSString stringWithFormat:@"buzzplayer://%@", [self.channel streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:@"GoodPlayer"]) {
        NSString *url = [NSString stringWithFormat:@"goodplayer://%@", [self.channel streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:@"Oplayer"]) {
        NSString *url = [NSString stringWithFormat:@"oplayer://%@", [self.channel streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    
}

@end
