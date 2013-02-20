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
#import "KxMovieViewController.h"
#import "CKRefreshControl.h"

@interface TVHChannelStoreProgramsViewController () <TVHChannelDelegate, UIActionSheetDelegate> {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
}

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
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
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
    [self.refreshControl endRefreshing];
}

- (void)didErrorLoadingEpgChannel:(NSError*) error {
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:NSLocalizedString(@"Network Error",nil) message:error.description];
    [notice setSticky:true];
    [notice show];
    [self.refreshControl endRefreshing];
}

- (IBAction)playStream:(UIBarButtonItem*)sender {
    NSString *actionSheetTitle = NSLocalizedString(@"Play Stream Options", nil);
    NSString *copy = NSLocalizedString(@"Copy to Clipboard", nil);
    NSString *buzz = @"Buzz Player";
    NSString *good = @"GoodPlayer";
    NSString *oplayer = @"Oplayer";
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    NSString *stream = NSLocalizedString(@"Stream Channel", nil);
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:stream
                                  otherButtonTitles:copy, buzz, good, oplayer, nil];
    //[actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet showFromBarButtonItem:sender  animated:YES];
}

- (void)streamChannel:(NSString*) path {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // increase buffering for .wmv, it solves problem with delaying audio frames
    //if ([path.pathExtension isEqualToString:@"wmv"])
    // //   parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
    
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    // disable buffering
    // parameters[KxMovieParameterMinBufferedDuration] = @(0.0f);
    
    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:path
                                                                               parameters:parameters];
    [self presentViewController:vc animated:YES completion:nil];
    //[self.navigationController pushViewController:vc animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:NSLocalizedString(@"Copy to Clipboard", nil)]) {
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
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Stream Channel", nil)]) {
        NSString *url = [NSString stringWithFormat:@"%@?mux=pass", [self.channel streamURL] ];
        [self streamChannel:url];
    }
    
}

@end
