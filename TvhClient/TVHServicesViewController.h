//
//  TVHServicesViewController.h
//  TvhClient
//
//  Created by Luis Fernandes on 09/11/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "TVHAdapterMux.h"

@interface TVHServicesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TVHAdapter *adapter;
@property (strong, nonatomic) TVHAdapterMux *adapterMux;
@end
