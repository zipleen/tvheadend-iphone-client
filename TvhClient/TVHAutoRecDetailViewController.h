//
//  TVHAutoRecDetailViewController.h
//  TvhClient
//
//  Created by zipleen on 3/14/13.
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
#import "TVHAutoRecItem.h"

@interface TVHAutoRecDetailViewController : UITableViewController
@property (nonatomic, weak) TVHAutoRecItem *item;
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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@end
