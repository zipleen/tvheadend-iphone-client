//
//  TVHEpgTableViewController.h
//  TvhClient
//
//  Created by Luis Fernandes on 3/10/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@interface TVHEpgTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSegmentedControl;
@property (weak, nonatomic) IBOutlet UIToolbar *filterToolBar;
- (IBAction)filterSegmentedControlClicked:(UISegmentedControl *)sender;
- (IBAction)showHideSegmentedBar:(UIBarButtonItem *)sender;

- (void)setFilterTag:(NSString*)tag;
@end
