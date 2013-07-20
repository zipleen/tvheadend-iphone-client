//
//  TVHRecordingsViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/27/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "TVHDvrStore.h"
#import "TVHAutoRecStore.h"
#import "SDSegmentedControl.h"

@interface TVHRecordingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TVHDvrStoreDelegate, TVHAutoRecStoreDelegate>
@property (weak, nonatomic) IBOutlet SDSegmentedControl *segmentedControl;
- (IBAction)segmentedDidChange:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)putTableInEditMode:(id)sender;

@end
