//
//  TVHDvrDetailViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 01/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHDvrItem.h"
#import "SDSegmentedControl.h"
#import "TVHEpgStore.h"
#import "TVHPlayStreamHelpController.h"

@interface TVHRecordingsDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TVHEpgStoreDelegate>
@property (weak, nonatomic) TVHDvrItem *dvrItem;

@property (weak, nonatomic) IBOutlet UIImageView *programImage;
@property (weak, nonatomic) IBOutlet UILabel *programTitle;
@property (weak, nonatomic) IBOutlet UIButton *record;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SDSegmentedControl *segmentedControl;

- (IBAction)segmentedDidChange:(id)sender;
- (IBAction)removeRecording:(id)sender;
- (IBAction)playStream:(id)sender;


@end
