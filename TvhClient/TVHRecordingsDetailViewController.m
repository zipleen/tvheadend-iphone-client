//
//  TVHDvrDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 01/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHRecordingsDetailViewController.h"
#import "TVHServer.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "TVHShowNotice.h"
#import "NSString+FileSize.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "UIView+ClosestParent.h"

@interface TVHRecordingsDetailViewController () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) NSArray *propertiesKeys;
@property (strong, nonatomic) id <TVHEpgStore> moreTimes;
@property (strong, nonatomic) NSArray *moreTimesItems;
@property (strong, nonatomic) TVHPlayStreamHelpController *help;
@end

@implementation TVHRecordingsDetailViewController{
    NSDateFormatter *dateFormatter;
    NSDateFormatter *hourFormatter;
}

- (id <TVHEpgStore>)moreTimes {
    if ( ! _moreTimes ) {
        TVHServer *server = [[self.dvrItem channelObject] tvhServer];
        _moreTimes = [server createEpgStoreWithName:@"MoreTimes"];
        //[self.moreTimes setFilterToChannelName:self.dvrItem.channel];
        [_moreTimes setFilterToProgramTitle:self.dvrItem.title];
        [_moreTimes setDelegate:self];
        [_moreTimes downloadEpgList];
    }
    return _moreTimes;
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
    if ([[notification name] isEqualToString:TVHDvrActionDidSucceedNotification] && [notification.object isEqualToString:@"recordEvent"]) {
        [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully added Recording", nil)];
    }
}

- (NSDictionary*)propertiesDict {
    NSMutableDictionary *recordingProperties = [[NSMutableDictionary alloc] init];
    
    if ( self.dvrItem.start ) {
        NSString *str = [NSString stringWithFormat:@"%@ - %@ (%ld min)", [dateFormatter stringFromDate:self.dvrItem.start], [hourFormatter stringFromDate:self.dvrItem.end], self.dvrItem.duration/(long)60 ];
        if ( str ) {
            [recordingProperties setObject:str forKey:@"Time"];
        }
    }
    
    if ( self.dvrItem.description && ![self.dvrItem.description isEqualToString:@"(null)"] ) {
        [recordingProperties setObject:self.dvrItem.description forKey:@"Description"];
    }
    
    if ( self.dvrItem.status && ![self.dvrItem.status isEqualToString:@"(null)"] ) {
        [recordingProperties setObject:self.dvrItem.status forKey:@"Status"];
    }
    
    if ( self.dvrItem.creator && ![self.dvrItem.creator isEqualToString:@"(null)"] ) {
        [recordingProperties setObject:self.dvrItem.creator forKey:@"Creator"];
    }
    
    if ( self.dvrItem.pri && ![self.dvrItem.pri isEqualToString:@"(null)"] ) {
        [recordingProperties setObject:self.dvrItem.pri forKey:@"Priority"];
    }
    
    if ( self.dvrItem.schedstate && ![self.dvrItem.schedstate isEqualToString:@"(null)"] ) {
        [recordingProperties setObject:self.dvrItem.schedstate forKey:@"Scheduled State"];
    }
    
    if ( self.dvrItem.filesize ) {
        NSString *fileSize = [NSString stringFromFileSize:self.dvrItem.filesize];
        if ( fileSize ) {
            [recordingProperties setObject:fileSize forKey:@"File Size"];
        }
    }
    
    if ( self.dvrItem.episode && ![self.dvrItem.episode isEqualToString:@"(null)"] ) {
        [recordingProperties setObject:self.dvrItem.episode forKey:@"Episode"];
    }
    
    return [recordingProperties copy];
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
    self.channelTitle.text = [self.dvrItem.channelObject name];
    [self.programImage sd_setImageWithURL:[NSURL URLWithString:[self.dvrItem.channelObject imageUrl]] placeholderImage:[UIImage imageNamed:@"tv2.png"]];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDvrNotification:)
                                                 name:TVHDvrActionDidSucceedNotification
                                               object:nil];
    
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    
    if ( DEVICE_HAS_IOS7 ) {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Play", @"toolbar play")];
    } else {
        factory.size = 16;
        [self.navigationItem.rightBarButtonItem setImage:[factory createImageForIcon:NIKFontAwesomeIconFilm]];
    }
    if (self.self.dvrItem.dvrType == RECORDING_UPCOMING) {
        [self.navigationItem setRightBarButtonItems:nil];
    }
    
    [self.record setTitle:NSLocalizedString(@"Remove", @"dvr recording remove button") forState:UIControlStateNormal];
    
    [self.segmentedControl setTitle:NSLocalizedString(@"Details", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"See Again", nil) forSegmentAtIndex:1];
    
    factory.size = 18;
    factory.colors = @[[UIColor grayColor]];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconTimes] forSegmentAtIndex:1];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconInfo] forSegmentAtIndex:0];
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
        [TVHAnalytics sendEventWithCategory:@"uiAction"
                                                        withAction:@"recordings"
                                                         withLabel:@"removeRecording"
                                                         withValue:[NSNumber numberWithInt:0]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        NSString *str = [self.properties objectForKey:[self.propertiesKeys objectAtIndex:indexPath.row]];
        unsigned int screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGSize size = [str
                        sizeWithFont:[UIFont systemFontOfSize:13]
                        constrainedToSize:CGSizeMake(screenWidth-40, CGFLOAT_MAX)];
        return size.height + 25 + self.fontSizeHack;
        
    }
    if ( self.segmentedControl.selectedSegmentIndex == 1 ) {
        return 60;
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
        NSInteger count = [self.moreTimesItems count];
        if ( count == 0 ) {
            return 1;
        }
        return count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramDetailViewTableItem" forIndexPath:indexPath];
    
    TVHEpg *epg;
    cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.clipsToBounds = YES;
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
	UILabel *descLabel = (UILabel *)[cell viewWithTag:101];
    UIButton *recordButton = (UIButton *)[cell viewWithTag:103];
    
    [recordButton setTitle:NSLocalizedString(@"Record", nil) forState:UIControlStateNormal];
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
            descLabel.text = [NSString stringWithFormat:@"%@\n%@ - %@ (%ld min)", epg.channel, [dateFormatter stringFromDate:epg.start], [hourFormatter stringFromDate:epg.end], epg.duration/(long)60 ];
        }
    }
    
    // resize the "description" label
    unsigned int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGSize size = [descLabel.text
                   sizeWithFont:descLabel.font
                   constrainedToSize:CGSizeMake(screenWidth-40, CGFLOAT_MAX)];
    descLabel.frame = CGRectMake(20, 20, screenWidth-40, size.height + self.fontSizeHack);
    
    if ( ! DEVICE_HAS_IOS7 ) {
        // line separator
        UIView *sepColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 1)];
        [sepColor setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
        [cell.contentView addSubview:sepColor];
    }
    
    return cell;
}

- (int)fontSizeHack {
    if ( DEVICE_HAS_IOS7 ) {
        return 10;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row % 2 ) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (IBAction)segmentedDidChange:(id)sender {
    [self moreTimes];
    [self.tableView reloadData];
}

- (void)didLoadEpg {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [[self.moreTimes epgStoreItems] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( ! [obj schedstate] ) {
            [items addObject:obj];
        }
    }];
    self.moreTimesItems = [items copy];
    [self.tableView reloadData];
}

- (IBAction)addRecordMoreItemsToTVHeadend:(id)sender {
    if( self.segmentedControl.selectedSegmentIndex == 1 ){
        // for "see again" items
        UITableViewCell* myCell = (UITableViewCell*)[UIView TVHClosestParent:@"UITableViewCell" ofView:sender];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:myCell];
        TVHEpg *epg = self.moreTimesItems[indexPath.row];
        if( ! [epg schedstate] ) {
            [epg addRecording];
        }
        
    }
    
    [TVHAnalytics sendEventWithCategory:@"uiAction"
                                                    withAction:@"recordings"
                                                     withLabel:@"addRecording"
                                                     withValue:[NSNumber numberWithInt:0]];
}


@end
