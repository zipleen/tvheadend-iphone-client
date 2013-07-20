//
//  TVHDvrDetailViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 01/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
@property (weak, nonatomic) IBOutlet UILabel *channelTitle;

- (IBAction)segmentedDidChange:(id)sender;
- (IBAction)removeRecording:(id)sender;
- (IBAction)playStream:(id)sender;


@end
