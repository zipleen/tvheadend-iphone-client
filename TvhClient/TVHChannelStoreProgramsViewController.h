//
//  TVHChannelListProgramsViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "TVHChannel.h"
#import "SDSegmentedControl.h"

@interface TVHChannelStoreProgramsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet SDSegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)playStream:(id)sender;
- (IBAction)segmentDidChange:(id)sender;
@property (nonatomic, weak) TVHChannel *channel;
@end
