//
//  TVHProgramDetailViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHEpg.h"
#import "TVHChannel.h"
#import "SDSegmentedControl.h"
#import "TVHEpgStore.h"

@interface TVHProgramDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TVHEpgStoreDelegate>

@property (weak, nonatomic) TVHEpg *epg;
@property (weak, nonatomic) TVHChannel *channel;
@property (weak, nonatomic) IBOutlet UIImageView *programImage;
@property (weak, nonatomic) IBOutlet UILabel *programTitle;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIButton *record;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SDSegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *channelTitle;

- (IBAction)segmentedDidChange:(id)sender;
- (IBAction)addAutoRecordToTVHeadend:(id)sender;
- (IBAction)addRecordMoreItemsToTVHeadend:(id)sender;
- (IBAction)playStream:(id)sender;

@end
