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

@interface TVHProgramDetailViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) TVHEpgStore *moreTimes;
@property (strong, nonatomic) NSArray *moreTimesItems;
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
    self.dateLabel.text = [NSString stringWithFormat:@"%@ (%d min)", [dateFormatter stringFromDate:self.epg.start], self.epg.duration/60 ];
    [self.programImage setImageWithURL:[NSURL URLWithString:self.channel.imageUrl] placeholderImage:[UIImage imageNamed:@"tv.png"]];
    
    
    // shadown
    self.programImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.programImage.layer.shadowOffset = CGSizeMake(0, 2);
    self.programImage.layer.shadowOpacity = 0.7f;
    self.programImage.layer.shadowRadius = 1.5;
    self.programImage.clipsToBounds = NO;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    
    [self.record setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0] forState:UIControlStateNormal];
    
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
    [self setDateLabel:nil];
    [super viewDidUnload];
}


- (IBAction)addRecordToTVHeadend:(id)sender {
    [self.epg addRecording];
}

- (IBAction)playStream:(id)sender {
    
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
        return [self.moreTimesItems count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProgramDetailViewTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.clipsToBounds = YES;
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *descLabel = (UILabel *)[cell viewWithTag:101];
    UIButton *recordButton = (UIButton *)[cell viewWithTag:103];
    descLabel.numberOfLines = 0;
    
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        recordButton.hidden = YES;
        if ( indexPath.row == 0 ) {
            titleLabel.text = @"Running Time";
            
            
            descLabel.text = [NSString stringWithFormat:@"%@ | %@", [hourFormatter stringFromDate:self.epg.start], [hourFormatter stringFromDate:self.epg.end]];
        }
        
        if ( indexPath.row == 1 ) {
            titleLabel.text = @"Description";
            descLabel.text = self.epg.description;
        }
    }

    if ( self.segmentedControl.selectedSegmentIndex == 1 ) {
        TVHEpg *epg = self.moreTimesItems[indexPath.row];
        titleLabel.text = epg.title;
        descLabel.text = [NSString stringWithFormat:@"%@ (%d min)", [dateFormatter stringFromDate:epg.start], epg.duration/60 ];
        
        // we need the button =)
        recordButton.hidden = NO;
        [recordButton setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0] forState:UIControlStateNormal];
    }
    
    // resize the "description" label
    CGSize size = [descLabel.text
              sizeWithFont:[UIFont systemFontOfSize:14]
              constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)];
    descLabel.frame = CGRectMake(20, 20, size.width, size.height);
    
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
    UIView *senderButton = (UIView*) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell*)[[senderButton superview]superview]];
    TVHEpg *epg = self.moreTimesItems[indexPath.row];
    [epg addRecording];
}
@end
