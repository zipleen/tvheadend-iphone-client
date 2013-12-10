//
//  TVHStatusSubscriptionsViewController.h
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/18/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "TVHStatusSubscriptionsStore.h"
#import "TVHAdaptersStore.h"
#import "TVHStatusInputStore.h"
#import "MGSplitViewController.h"

@interface TVHStatusSubscriptionsViewController : UITableViewController <TVHStatusSubscriptionsDelegate, TVHAdaptersDelegate, TVHStatusInputDelegate>
- (IBAction)switchPolling:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchButton;
@property (weak, nonatomic) MGSplitViewController *splitViewController;
@end
