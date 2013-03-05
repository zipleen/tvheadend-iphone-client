//
//  TVHProgramDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHProgramDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "WBSuccessNoticeView.h"
#import "TVHPlayStreamHelpController.h"

@interface TVHProgramDetailViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) TVHEpgStore *moreTimes;
@property (strong, nonatomic) NSArray *moreTimesItems;
@property (strong, nonatomic) TVHPlayStreamHelpController *help;
@end

@implementation TVHProgramDetailViewController {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *hourFormatter;
}

- (void) receiveDvrNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"didSuccessDvrAction"] && [notification.object isEqualToString:@"recordEvent"]) {
        WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInView:self.view title:NSLocalizedString(@"Succesfully added Recording", nil)];
        [notice show];
    }
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
    
    self.programTitle.text = self.epg.title;
    [self.programImage setImageWithURL:[NSURL URLWithString:self.channel.imageUrl] placeholderImage:[UIImage imageNamed:@"tv.png"]];
    
    
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
    [self setTime:nil];
    self.epg = nil;
    self.channel = nil;
    [self setRecord:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
    [self setSegmentedControl:nil];
    self.moreTimes = nil;
    self.moreTimesItems = nil;
    self.help = nil;
    [super viewDidUnload];
}


- (IBAction)addAutoRecordToTVHeadend:(id)sender {
    
}

#pragma MARK table view delegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        if ( indexPath.row == 1 ) {
            if( !self.epg.description ) {
                return 0;
            }
            CGSize size = [self.epg.description
                           sizeWithFont:[UIFont systemFontOfSize:14]
                           constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
            return size.height + 25;
        }
    }
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( self.segmentedControl.selectedSegmentIndex == 0 )
    {
        return 2;
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
        epg = self.epg;
        if ( indexPath.row == 0 ) {
            titleLabel.text = NSLocalizedString(@"Time", nil);
        }
        
        if ( indexPath.row == 1 ) {
            titleLabel.text = NSLocalizedString(@"Description", nil);
            descLabel.text = self.epg.description;
            recordButton.hidden = YES;
        }
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
    
    // index = 0 and row = 1 is the description label
    if ( ! (self.segmentedControl.selectedSegmentIndex == 0 && indexPath.row == 1) ) {
        if( epg ) {
            descLabel.text = [NSString stringWithFormat:@"%@ - %@ (%d min)", [dateFormatter stringFromDate:epg.start], [hourFormatter stringFromDate:epg.end], epg.duration/60 ];
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
            [self.moreTimes setFilterToChannelName:self.channel.name];
            [self.moreTimes setFilterToProgramTitle:self.epg.title];
            [self.moreTimes setDelegate:self];
            [self.moreTimes downloadEpgList];
        }
    }
    [self.tableView reloadData];
}

- (void) didLoadEpg:(TVHEpgStore*)epgStore {
    // this search will turn out to have our *current* listening program. we should delete that
    NSMutableArray *items = [[epgStore getEpgList] mutableCopy];
    [items removeObject:self.epg];
    
    self.moreTimesItems = [items copy];
    [self.tableView reloadData];
}

- (IBAction)addRecordMoreItemsToTVHeadend:(id)sender {
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        [self.epg addRecording];
    } else if( self.segmentedControl.selectedSegmentIndex == 1 ){
        UIView *senderButton = (UIView*) sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell*)[[senderButton superview]superview]];
        TVHEpg *epg = self.moreTimesItems[indexPath.row];
        [epg addRecording];
    }
}

- (IBAction)playStream:(id)sender {
    if(!self.help) {
        self.help = [[TVHPlayStreamHelpController alloc] init];
    }
    
    [self.help playStream:sender withChannel:self.channel withVC:self];
}
@end
