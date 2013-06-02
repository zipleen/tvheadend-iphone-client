//
//  TVHDvrDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 01/03/13.
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

#import "TVHRecordingsDetailViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "TVHShowNotice.h"
#import "NSString+FileSize.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface TVHRecordingsDetailViewController () <UIActionSheetDelegate, UIAlertViewDelegate>
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
        [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully added Recording", nil)];
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
    
    if ( self.dvrItem.episode && ![self.dvrItem.episode isEqualToString:@"(null)"] ) {
        [p setObject:self.dvrItem.episode forKey:@"Episode"];
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
    
    self.programTitle.text = self.dvrItem.fullTitle;
    self.channelTitle.text = self.dvrItem.channel;
    [self.programImage setImageWithURL:[NSURL URLWithString:self.dvrItem.chicon] placeholderImage:[UIImage imageNamed:@"tv2.png"]];
    self.properties = [self propertiesDict];
    self.propertiesKeys = [[self.properties allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    
    // shadow
    self.programImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.programImage.layer.shadowOffset = CGSizeMake(0, 2);
    self.programImage.layer.shadowOpacity = 0.7f;
    self.programImage.layer.shadowRadius = 1.5;
    self.programImage.clipsToBounds = NO;
    self.programImage.contentMode = UIViewContentModeScaleAspectFit;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    
    [self.record setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [self.record setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDvrNotification:)
                                                 name:@"didSuccessDvrAction"
                                               object:nil];
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    factory.size = 16;
    [self.navigationItem.rightBarButtonItem setImage:[factory createImageForIcon:NIKFontAwesomeIconFilm]];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"Details", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"See Again", nil) forSegmentAtIndex:1];
    
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
    self.moreTimesItems = nil;
    [self setRecord:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
    [self setSegmentedControl:nil];
    self.moreTimes = nil;
    self.properties = nil;
    self.propertiesKeys = nil;
    self.help = nil;
    [self setChannelTitle:nil];
    [super viewDidUnload];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        [self.dvrItem deleteRecording];
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (IBAction)removeRecording:(id)sender {
    UIAlertView *questionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove recording", nil)
                                                         message:NSLocalizedString(@"Are your sure you want to remove the recording?", @"Question in Alert view")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"No", nil)
                                               otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    [questionAlert show];
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
        unsigned int screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGSize size = [str
                        sizeWithFont:[UIFont systemFontOfSize:13]
                        constrainedToSize:CGSizeMake(screenWidth-40, CGFLOAT_MAX)];
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
        titleLabel.text = NSLocalizedString([self.propertiesKeys objectAtIndex:indexPath.row] , nil);
        descLabel.text = [self.properties objectForKey:[self.propertiesKeys objectAtIndex:indexPath.row]];
        recordButton.hidden = YES;
    } else if ( self.segmentedControl.selectedSegmentIndex == 1 ) {
        // we have self.moreTimes so the message is not shown before knowing in fact that there are no more programs available
        if ( [self.moreTimesItems count] == 0 && self.moreTimes ) {
            titleLabel.text = NSLocalizedString(@"No more programs available.", nil);
            recordButton.hidden = YES;
            descLabel.text = @"";
        } else if( [self.moreTimesItems count] > 0 ) {
            epg = self.moreTimesItems[indexPath.row];
            titleLabel.text = epg.title;
            descLabel.text = [NSString stringWithFormat:@"%@ - %@ (%d min)", [dateFormatter stringFromDate:epg.start], [hourFormatter stringFromDate:epg.end], epg.duration/60 ];
        }
    }
    
    // resize the "description" label
    unsigned int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGSize size = [descLabel.text
                   sizeWithFont:[UIFont systemFontOfSize:13]
                   constrainedToSize:CGSizeMake(screenWidth-40, CGFLOAT_MAX)];
    descLabel.frame = CGRectMake(20, 20, size.width, size.height);
    
    // line separator
    UIView *sepColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 1)];
    [sepColor setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [cell.contentView addSubview:sepColor];
    
    //UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"separator.png"]];
    //[cell.contentView addSubview:separator];
    
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
            self.moreTimes = [[TVHEpgStore alloc] initWithTvhServer:[[self.dvrItem channelObject] tvhServer]];
            [self.moreTimes setFilterToChannelName:self.dvrItem.channel];
            [self.moreTimes setFilterToProgramTitle:self.dvrItem.title];
            [self.moreTimes setDelegate:self];
            [self.moreTimes downloadEpgList];
        }
    }
    [self.tableView reloadData];
}

- (void) didLoadEpg:(TVHEpgStore*)epgStore {
    self.moreTimesItems = [epgStore epgStoreItems];
    [self.tableView reloadData];
}

@end
