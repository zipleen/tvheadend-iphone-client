//
//  TVHProgramDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/11/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHProgramDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "TVHShowNotice.h"
#import "TVHPlayStreamHelpController.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface TVHProgramDetailViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) NSArray *propertiesKeys;
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
        [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully added Recording", nil)];
    }
    if ([[notification name] isEqualToString:@"didSuccessDvrAction"] && [notification.object isEqualToString:@"recordSeries"]) {
        [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully added Auto Recording", nil)];
    }
}

- (NSDictionary*)propertiesDict {
    NSMutableDictionary *p = [[NSMutableDictionary alloc] init];
    
    if ( self.epg.start ) {
        NSString *str = [NSString stringWithFormat:@"%@ - %@ (%d min)", [dateFormatter stringFromDate:self.epg.start], [hourFormatter stringFromDate:self.epg.end], self.epg.duration/60 ];
        [p setObject:str forKey:@"Time"];
    }
    
    if ( self.epg.description && ![self.epg.description isEqualToString:@"(null)"] ) {
        [p setObject:self.epg.description forKey:@"Description"];
    }
    
    if ( self.epg.subtitle && ![self.epg.subtitle isEqualToString:@"(null)"] ) {
        [p setObject:self.epg.subtitle forKey:@"Subtitle"];
    }
    
    if ( self.epg.episode && ![self.epg.episode isEqualToString:@"(null)"] ) {
        [p setObject:self.epg.episode forKey:@"Episode"];
    }
    
    if ( self.epg.schedstate && ![self.epg.schedstate isEqualToString:@"(null)"] ) {
        [p setObject:self.epg.schedstate forKey:@"Schedule State"];
    }
    
    if ( self.epg.serieslink && ![self.epg.serieslink isEqualToString:@"(null)"] ) {
        [p setObject:self.epg.serieslink forKey:@"Series Link"];
    }
    
    return [p copy];
}

- (void)viewDidAppear:(BOOL)animated
{
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker sendView:NSStringFromClass([self class])];
#endif
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
    
    self.programTitle.text = self.epg.fullTitle;
    self.channelTitle.text = self.epg.channel;
    [self.programImage setImageWithURL:[NSURL URLWithString:self.epg.chicon] placeholderImage:[UIImage imageNamed:@"tv2.png"]];
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
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    factory.size = 32*2;
    factory.colors = @[[UIColor grayColor]];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconTime] forSegmentAtIndex:1];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconInfoSign] forSegmentAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setProgramTitle:nil];
    [self setProgramImage:nil];
    self.epg = nil;
    self.channel = nil;
    [self setRecord:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
    [self setSegmentedControl:nil];
    self.moreTimes = nil;
    self.moreTimesItems = nil;
    self.help = nil;
    self.properties = nil;
    self.propertiesKeys = nil;
    [self setChannelTitle:nil];
    [super viewDidUnload];
}

#pragma MARK table view delegate

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        NSString *str = [self.properties objectForKey:[self.propertiesKeys objectAtIndex:indexPath.row]];
        unsigned int screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGSize size = [str
                       sizeWithFont:[UIFont systemFontOfSize:14]
                       constrainedToSize:CGSizeMake(screenWidth-20, CGFLOAT_MAX)];
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
    if(cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
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
        titleLabel.text = NSLocalizedString([self.propertiesKeys objectAtIndex:indexPath.row] , nil);
        descLabel.text = [self.properties objectForKey:[self.propertiesKeys objectAtIndex:indexPath.row]];
        recordButton.hidden = YES;
        
        if( [titleLabel.text isEqualToString:NSLocalizedString(@"Time", nil)] ) {
            recordButton.hidden = NO;
        }
        
    } else if ( self.segmentedControl.selectedSegmentIndex == 1 ) {
        // we have !self.moreTimes so the message is not shown before knowing in fact that there are no more programs available
        if ( [self.moreTimesItems count] == 0 && self.moreTimes ) {
            titleLabel.text = NSLocalizedString(@"No more programs available.", nil);
            recordButton.hidden = YES;
            descLabel.text = @"";
        } else if( [self.moreTimesItems count] > 0 ) {
            epg = self.moreTimesItems[indexPath.row];
            titleLabel.text = epg.fullTitle;
            descLabel.text = [NSString stringWithFormat:@"%@ - %@ (%d min)", [dateFormatter stringFromDate:epg.start], [hourFormatter stringFromDate:epg.end], epg.duration/60 ];
        }
    }
    
    // resize the "description" label
    unsigned int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGSize size = [descLabel.text
              sizeWithFont:[UIFont systemFontOfSize:14]
              constrainedToSize:CGSizeMake(screenWidth-20, CGFLOAT_MAX)];
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

- (void)didLoadEpg:(TVHEpgStore*)epgStore {
    // this search will turn out to have our *current* listening program. we should delete that
    NSMutableArray *items = [[epgStore epgStoreItems] mutableCopy];
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

- (IBAction)addAutoRecordToTVHeadend:(id)sender {
    [self.epg addAutoRec];
}

- (IBAction)playStream:(id)sender {
    if(!self.help) {
        self.help = [[TVHPlayStreamHelpController alloc] init];
    }
    
    [self.help playStream:sender withChannel:self.channel withVC:self];
}
@end
