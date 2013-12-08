//
//  TVHDebugLogViewController.h
//  TvhClient
//
//  Created by Luis Fernandes on 09/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "TVHLogStore.h"
#import "MGSplitViewController.h"

@interface TVHDebugLogViewController : UITableViewController <TVHLogDelegate, MGSplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *debugButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) MGSplitViewController *splitViewController;
- (IBAction)debugButton:(UIBarButtonItem *)sender;
- (IBAction)clearLog:(id)sender;
- (IBAction)moveSplit:(id)sender;

@end
