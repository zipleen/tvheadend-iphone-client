//
//  TVHProgramDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/11/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHProgramDetailViewController.h"
#import "TVHServer.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "TVHShowNotice.h"
#import "TVHPlayStreamHelpController.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "TVHImageCache.h"
#import "UIView+ClosestParent.h"

@interface TVHProgramDetailViewController () <UIActionSheetDelegate>
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) NSArray *propertiesKeys;
@property (strong, nonatomic) id <TVHEpgStore> moreTimes;
@property (strong, nonatomic) NSArray *moreTimesItems;
@property (strong, nonatomic) TVHPlayStreamHelpController *help;
@end

@implementation TVHProgramDetailViewController {
    NSDateFormatter *dateFormatter;
    NSDateFormatter *hourFormatter;
}

- (id <TVHEpgStore>)moreTimes {
    if ( ! _moreTimes ) {
        TVHServer *server = [self.channel tvhServer];
        _moreTimes = [server createEpgStoreWithName:@"MoreTimes"];
        //[self.moreTimes setFilterToChannelName:self.channel.name];
        [_moreTimes setFilterToProgramTitle:self.epg.title];
        [_moreTimes setDelegate:self];
        [_moreTimes downloadEpgList];
    }
    return _moreTimes;
}

- (void)receiveDvrNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:TVHDvrActionDidSucceedNotification] && ([notification.object isEqualToString:@"recordEvent"] || [notification.object isEqualToString:@"api/idnode/delete"] )) {
        [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully added Recording", nil)];
    }
    if ([[notification name] isEqualToString:TVHDvrActionDidSucceedNotification] && ([notification.object isEqualToString:@"recordSeries"] || [notification.object isEqualToString:@"api/dvr/autorec/create"])) {
        [TVHShowNotice successNoticeInView:self.view title:NSLocalizedString(@"Succesfully added Auto Recording", nil)];
    }
}

- (NSDictionary*)propertiesDict {
    NSMutableDictionary *epgProperties = [[NSMutableDictionary alloc] init];
    
    if ( self.epg.start ) {
        NSString *str = [NSString stringWithFormat:@"%@ - %@ (%ld min)", [dateFormatter stringFromDate:self.epg.start], [hourFormatter stringFromDate:self.epg.end], self.epg.duration/(long)60 ];
        if ( str ) {
            [epgProperties setObject:str forKey:@"Time"];
        }
    }
    
    if ( self.epg.description && ![self.epg.description isEqualToString:@"(null)"] ) {
        [epgProperties setObject:self.epg.description forKey:@"Description"];
    }
    
    if ( self.epg.subtitle && ![self.epg.subtitle isEqualToString:@"(null)"] ) {
        [epgProperties setObject:self.epg.subtitle forKey:@"Subtitle"];
    }
    
    if ( self.epg.episode && ![self.epg.episode isEqualToString:@"(null)"] ) {
        [epgProperties setObject:self.epg.episode forKey:@"Episode"];
    }
    
    if ( self.epg.schedstate && ![self.epg.schedstate isEqualToString:@"(null)"] ) {
        [epgProperties setObject:self.epg.schedstate forKey:@"Schedule State"];
    }
    
    return [epgProperties copy];
}

- (void)handleSwipeFromRight:(UISwipeGestureRecognizer *)recognizer {
    if ( recognizer.state == UIGestureRecognizerStateEnded ) {
        NSInteger sel = [self.segmentedControl selectedSegmentIndex] -1;
        if (sel >= 0 ) {
            [self.segmentedControl setSelectedSegmentIndex:sel];
            [self segmentedDidChange:self.segmentedControl];
        }
    }
}

- (void)handleSwipeFromLeft:(UISwipeGestureRecognizer *)recognizer {
    if ( recognizer.state == UIGestureRecognizerStateEnded ) {
        NSInteger sel = [self.segmentedControl selectedSegmentIndex] + 1;
        if (sel < [self.segmentedControl numberOfSegments] ) {
            [self.segmentedControl setSelectedSegmentIndex:sel];
            [self segmentedDidChange:self.segmentedControl];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [TVHAnalytics sendView:NSStringFromClass([self class])];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,
                                    self.tableView);
    [super viewDidAppear:animated];
}

- (void)setSegmentNames {
    [self.segmentedControl setTitle:NSLocalizedString(@"Details", nil) forSegmentAtIndex:0];
    [self.segmentedControl setTitle:NSLocalizedString(@"See Again", nil) forSegmentAtIndex:1];
}

- (void)setSegmentIcons {
    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
    factory.size = 18;
    factory.colors = @[[UIColor grayColor]];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconTime] forSegmentAtIndex:1];
    [self.segmentedControl setImage:[factory createImageForIcon:NIKFontAwesomeIconInfoSign] forSegmentAtIndex:0];
    
    if ( DEVICE_HAS_IOS7 ) {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Play", @"toolbar play")];
    } else {
        NIKFontAwesomeIconFactory *factory1 = [NIKFontAwesomeIconFactory barButtonItemIconFactory];
        factory1.size = 16;
        [self.navigationItem.rightBarButtonItem setImage:[factory1 createImageForIcon:NIKFontAwesomeIconFilm]];
    }
    [self.navigationItem.rightBarButtonItem setAccessibilityLabel:NSLocalizedString(@"Play Channel", @"accessbility")];
}

- (void)setProgramImageShadow {
    // shadow
    self.programImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.programImage.layer.shadowOffset = CGSizeMake(0, 2);
    self.programImage.layer.shadowOpacity = 0.7f;
    self.programImage.layer.shadowRadius = 1.5;
    self.programImage.clipsToBounds = NO;
    self.programImage.contentMode = UIViewContentModeScaleAspectFit;

}

- (void)setHeaderChannelData {
    self.programTitle.text = self.epg.fullTitle;
    self.channelTitle.text = self.epg.channel;
    [self.programImage sd_setImageWithURL:[NSURL URLWithString:self.epg.chicon] placeholderImage:[UIImage imageNamed:@"tv2.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error && image) {
            self.programImage.image = [TVHImageCache resizeImage:image];
        }
    } ];
    
    [self setProgramImageShadow];
}

- (void)setScreenTheme {
    self.view.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    if ( [self.epg serieslink] == 1 ) {
        [self.record setTitle:NSLocalizedString(@"Rec Series", @"Record series button") forState:UIControlStateNormal];
    } else {
        [self.record setTitle:NSLocalizedString(@"AutoRec", @"Auto rec button") forState:UIControlStateNormal];
    }
}

- (void)initFormatters {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"E d MMM, HH:mm"];
    
    hourFormatter = [[NSDateFormatter alloc] init];
    hourFormatter.dateFormat = @"HH:mm";

}

- (void)setChannelPropertiesFromChannel {
    self.properties = [self propertiesDict];
    self.propertiesKeys = [[self.properties allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDvrNotification:)
                                                 name:@"didSuccessDvrAction"
                                               object:nil];
    
    [self initFormatters];
    [self setHeaderChannelData];
    [self setChannelPropertiesFromChannel];
    [self setScreenTheme];
    
    [self setSegmentIcons];
    [self setSegmentNames];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    //[self.refreshControl addTarget:self action:@selector(pullToRefreshViewShouldRefresh) forControlEvents:UIControlEventValueChanged];
    if ( ! DEVICE_HAS_IOS7 ) {
        UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(handleSwipeFromRight:)];
        [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.tableView addGestureRecognizer:rightGesture];
        
        UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(handleSwipeFromLeft:)];
        [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.tableView addGestureRecognizer:leftGesture];
    }
    [self moreTimes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.help dismissActionSheet];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
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
}

#pragma MARK table view delegate

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

- (int)fontSizeHack {
    if ( DEVICE_HAS_IOS7 ) {
        return 10;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( self.segmentedControl.selectedSegmentIndex == 0 ) {
        NSString *str = [self.properties objectForKey:[self.propertiesKeys objectAtIndex:indexPath.row]];
        unsigned int screenWidth = [self.view bounds].size.width;
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
        NSUInteger count = [self.moreTimesItems count];
        if ( count == 0 ) {
            return 1;
        }
        return count;
    }
    return 0;
}

- (void)setStyleForRecordButton:(UIButton*)recordButton forEpg:(TVHEpg*)epg {
    
    if ( [[epg schedstate] isEqualToString:@"scheduled"] || [[epg schedstate] isEqualToString:@"recording"] ) {
        //[recordButton setTitle:NSLocalizedString(@"Remove", nil) forState:UIControlStateNormal];
        [recordButton setHidden:YES];
    } else {
        [recordButton setTitle:NSLocalizedString(@"Record", nil) forState:UIControlStateNormal];
    }
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
    
    descLabel.numberOfLines = 0;
    recordButton.hidden = NO;
    
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        epg = self.epg;
        titleLabel.text = NSLocalizedString([self.propertiesKeys objectAtIndex:indexPath.row] , nil);
        descLabel.text = [self.properties objectForKey:[self.propertiesKeys objectAtIndex:indexPath.row]];
        recordButton.hidden = YES;
        
        if( [titleLabel.text isEqualToString:NSLocalizedString(@"Time", nil)] ) {
            recordButton.hidden = NO;
            [self setStyleForRecordButton:recordButton forEpg:epg];
        }
        
    } else if ( self.segmentedControl.selectedSegmentIndex == 1 ) {
        // we have !self.moreTimes so the message is not shown before knowing in fact that there are no more programs available
        if ( [self.moreTimesItems count] == 0 && self.moreTimes ) {
            titleLabel.text = NSLocalizedString(@"No more programs available.", nil);
            recordButton.hidden = YES;
            descLabel.text = @"";
        } else if( [self.moreTimesItems count] > 0 ) {
            epg = self.moreTimesItems[indexPath.row];
            [self setStyleForRecordButton:recordButton forEpg:epg];
            titleLabel.text = epg.fullTitle;
            descLabel.text = [NSString stringWithFormat:@"%@\n%@ - %@ (%ld min)", [epg.channelObject name], [dateFormatter stringFromDate:epg.start], [hourFormatter stringFromDate:epg.end], epg.duration/(long)60 ];
        }
    }
    
    // resize the "description" label
    unsigned int screenWidth = [self.view bounds].size.width;
    CGSize size = [descLabel.text
                   sizeWithFont:descLabel.font
              constrainedToSize:CGSizeMake(screenWidth-40, CGFLOAT_MAX)];
    descLabel.frame = CGRectMake(20, 20, screenWidth-40, size.height + self.fontSizeHack);
    
    if ( ! DEVICE_HAS_IOS7 ) {
        // line separator
        UIView *sepColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 1)];
        [sepColor setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    }
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (IBAction)segmentedDidChange:(id)sender {
    [self.tableView reloadData];
}

- (void)willLoadEpg {
    
}

- (void)didLoadEpg {
    // this search will turn out to have our *current* listening program. we should delete that
    NSMutableArray *items = [[self.moreTimes epgStoreItems] mutableCopy];
    [items removeObject:self.epg];
    
    self.moreTimesItems = [items copy];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (IBAction)addRecordMoreItemsToTVHeadend:(id)sender {
    // for our program
    if( self.segmentedControl.selectedSegmentIndex == 0 ) {
        if ( ! [self.epg schedstate] ) {
            [self.epg addRecording];
        }
    } else if( self.segmentedControl.selectedSegmentIndex == 1 ){
        // for "see again" items
        UITableViewCell* myCell = (UITableViewCell*)[UIView TVHClosestParent:@"UITableViewCell" ofView:sender];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:myCell];
        TVHEpg *epg = self.moreTimesItems[indexPath.row];
        if( ! [self.epg schedstate] ) {
            [epg addRecording];
        }
        
    }
    
    [TVHAnalytics sendEventWithCategory:@"uiAction"
                                                    withAction:@"recordings"
                                                     withLabel:@"addRecording"
                                                     withValue:[NSNumber numberWithInt:0]];
}

- (IBAction)addAutoRecordToTVHeadend:(id)sender {
    [self.epg addAutoRec];
    [TVHAnalytics sendEventWithCategory:@"uiAction"
                                                    withAction:@"recordings"
                                                     withLabel:@"addRecordingRec"
                                                     withValue:[NSNumber numberWithInt:0]];
}

- (IBAction)playStream:(id)sender {
    if(!self.help) {
        self.help = [[TVHPlayStreamHelpController alloc] init];
    }
    
    [self.help playStream:sender withChannel:self.channel withVC:self];
}
@end
