//
//  TVHRecordingsViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/27/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHDvrStore.h"
#import "SDSegmentedControl.h"

@interface TVHRecordingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TVHDvrStoreDelegate>
@property (weak, nonatomic) IBOutlet SDSegmentedControl *segmentedControl;
- (IBAction)segmentedDidChange:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
