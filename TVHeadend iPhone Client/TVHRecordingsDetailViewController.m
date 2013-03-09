//
//  TVHDvrDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 01/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHRecordingsDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "WBSuccessNoticeView.h"
#import "NSString+FileSize.h"

@interface TVHRecordingsDetailViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) NSArray *propertiesKeys;
@property (strong, nonatomic) TVHEpgStore *moreTimes;
@property (strong, nonatomic) NSArray *moreTimesItems;
@property (strong, nonatomic) TVHPlayStreamHelpController *help;
@end

@implementation TVHRecordingsDetailViewController{
    NSDateFormatter *dateFormatter;
    NSDateFormatter *hourFormatter;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) receiveDvrNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"didSuccessDvrAction"] && [notification.object isEqualToString:@"recordEvent"]) {
        WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInView:self.view title:NSLocalizedString(@"Succesfully added Recording", nil)];
        [notice show];
    }
}

- (NSDictionary*)propertiesDict {
    NSMutableDictionary *p = [[NSMutableDictionary alloc] init];
    
    if ( self.dvrItem.start ) {
        NSString *str = [NSString stringWithFormat:@"%@ - %@ (%d min)", [dateFormatter stringFromDate:self.dvrItem.start], [hourFormatter stringFromDate:self.dvrItem.end], self.dvrItem.duration/60 ];
        [p setObject:str forKey:@"Time"];
    }
    
    if ( self.dvrItem.description && ![self.dvrItem.description isEqualToString:@"(null)"] ) {
        [p setObject:self.dvrItem.description forKey:@"Description"];
    }
    
    if ( self.dvrItem.status && ![self.dvrItem.status isEqualToString:@"(null)"] ) {
        [p setObject:self.dvrItem.status forKey:@"Status"];
    }
    
    if ( self.dvrItem.creator && ![self.dvrItem.creator isEqualToString:@"(null)"] ) {
        [p setObject:self.dvrItem.creator forKey:@"Creator"];
    }
    
    if ( self.dvrItem.pri && ![self.dvrItem.pri isEqualToString:@"(null)"] ) {
        [p setObject:self.dvrItem.pri forKey:@"Priority"];
    }
    
    if ( self.dvrItem.schedstate && ![self.dvrItem.schedstate isEqualToString:@"(null)"] ) {
        [p setObject:self.dvrItem.schedstate forKey:@"Scheduled State"];
    }
    
    if ( self.dvrItem.filesize ) {
        [p setObject:[NSString stringFromFileSize:self.dvrItem.filesize] forKey:@"File Size"];
    }
    
    return [p copy];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
        
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E d MMM, HH:mm"];
    
    hourFormatter = [[NSDateFormatter alloc] init];
    hourFormatter.dateFormat = @"HH:mm";
    
    self.programTitle.text = self.dvrItem.title;
    [self.programImage setImageWithURL:[NSURL URLWithString:self.dvrItem.chicon] placeholderImage:[UIImage imageNamed:@"tv2.png"]];
    self.properties = [self propertiesDict];
    self.propertiesKeys = [[self.properties allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    
    // shadown
    self.programImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.programImage.layer.shadowOffset = CGSizeMake(0, 2);
    self.programImage.layer.shadowOpacity = 0.7f;
    self.programImage.layer.shadowRadius = 1.5;
    self.programImage.clipsToBounds = NO;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    
    [self.record setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [self.record setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDvrNotification:)
                                                 name:@"didSuccessDvrAction"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setProgramTitle:nil];
    [self setProgramImage:nil];
    self.moreTimesItems = nil;
    [self setRecord:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
    [self setSegmentedControl:nil];
    self.moreTimes = nil;
    self.properties = nil;
    self.propertiesKeys = nil;
    self.help = nil;
    [super viewDidUnload];
}

- (IBAction)removeRecording:(id)sender {
    [self.dvrItem deleteRecording];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)playStream:(id)sender {
    
    if(!self.help) {
        self.help = [[TVHPlayStreamHelpController alloc] init];
    }
    
    [self.help playDvr:sender withDvrItem:self.dvrItem withVC:self];
    
}

#pragma MARK table view delegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        NSString *str = [self.properties objectForKey:[self.propertiesKeys objectAtIndex:indexPath.row]];
        
        CGSize size = [str
                        sizeWithFont:[UIFont systemFontOfSize:14]
                        constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
        return size.height + 25;
        
    }
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( self.segmentedControl.selectedSegmentIndex == 0 )
    {
        return [self.propertiesKeys count];
    }
    if ( self.segmentedControl.selectedSegmentIndex == 1 ) {
        int count = [self.moreTimesItems count];
        if ( count == 0 ) {
            return 1;
        }
        return count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TVHEpg *epg;
    static NSString *CellIdentifier = @"ProgramDetailViewTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.clipsToBounds = YES;
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *descLabel = (UILabel *)[cell viewWithTag:101];
    UIButton *recordButton = (UIButton *)[cell viewWithTag:103];
    [recordButton setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [recordButton setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    
    descLabel.numberOfLines = 0;
    recordButton.hidden = NO;
    
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        titleLabel.text = NSLocalizedString([self.propertiesKeys objectAtIndex:indexPath.row] , nil);
        descLabel.text = [self.properties objectForKey:[self.propertiesKeys objectAtIndex:indexPath.row]];
        recordButton.hidden = YES;
    } else if ( self.segmentedControl.selectedSegmentIndex == 1 ) {
        // we have !self.moreTimes so the message is not shown before knowing in fact that there are no more programs available
        if ( [self.moreTimesItems count] == 0 && self.moreTimes ) {
            titleLabel.text = NSLocalizedString(@"No more programs available.", nil);
            recordButton.hidden = YES;
            descLabel.text = @"";
        } else if( [self.moreTimesItems count] > 0 ) {
            epg = self.moreTimesItems[indexPath.row];
            titleLabel.text = epg.title;
        }
    }
    
    // resize the "description" label
    CGSize size = [descLabel.text
                   sizeWithFont:[UIFont systemFontOfSize:14]
                   constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
    descLabel.frame = CGRectMake(20, 20, size.width, size.height);
    
    // line separator
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    [cell.contentView addSubview:separator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row % 2 ) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    }
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (IBAction)segmentedDidChange:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex == 1) {
        // on our first time we click more items, we'll spawn a new epgstore and filter for our channel name + program title
        if ( ! self.moreTimes ) {
            self.moreTimes = [[TVHEpgStore alloc] init];
            [self.moreTimes setFilterToChannelName:self.dvrItem.channel];
            [self.moreTimes setFilterToProgramTitle:self.dvrItem.title];
            [self.moreTimes setDelegate:self];
            [self.moreTimes downloadEpgList];
        }
    }
    [self.tableView reloadData];
}

- (void) didLoadEpg:(TVHEpgStore*)epgStore {
    self.moreTimesItems = [epgStore getEpgList];
    [self.tableView reloadData];
}

@end
