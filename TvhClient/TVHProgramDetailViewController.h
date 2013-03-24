//
//  TVHProgramDetailViewController.h
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
@property (weak, nonatomic) IBOutlet UIButton *record;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SDSegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *channelTitle;

- (IBAction)segmentedDidChange:(id)sender;
- (IBAction)addAutoRecordToTVHeadend:(id)sender;
- (IBAction)addRecordMoreItemsToTVHeadend:(id)sender;
- (IBAction)playStream:(id)sender;

@end
