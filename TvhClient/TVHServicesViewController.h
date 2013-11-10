//
//  TVHServicesViewController.h
//  TvhClient
//
//  Created by zipleen on 09/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHAdapterMux.h"

@interface TVHServicesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TVHAdapter *adapter;
@property (strong, nonatomic) TVHAdapterMux *adapterMux;
@end
