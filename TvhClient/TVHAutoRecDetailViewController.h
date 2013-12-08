//
//  TVHAutoRecDetailViewController.h
//  TvhClient
//
//  Created by Luis Fernandes on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "TVHAutoRecItem.h"

@interface TVHAutoRecDetailViewController : UITableViewController
@property (nonatomic, strong) TVHAutoRecItem *item;
@property (weak, nonatomic) IBOutlet UISwitch *itemEnable;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemChannel;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemTag;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemWeekdays;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemPriority;
@property (weak, nonatomic) IBOutlet UITextField *itemCreatedBy;
@property (weak, nonatomic) IBOutlet UITextField *itemComment;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemDvrConfig;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemGenre;
@property (weak, nonatomic) IBOutlet UITableViewCell *itemStartAround;
@property (weak, nonatomic) IBOutlet UITextField *itemTitle;
- (IBAction)saveButton:(id)sender;

@end
