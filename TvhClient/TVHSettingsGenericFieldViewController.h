//
//  TVHSettingsGenericFieldViewController.h
//  TvhClient
//
//  Created by Luis Fernandes on 3/25/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>

@interface TVHSettingsGenericFieldViewController : UITableViewController
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *sectionHeader;
@property (nonatomic) NSInteger selectedOption;
@property (copy) void (^responseBack)(NSInteger row);
@end
