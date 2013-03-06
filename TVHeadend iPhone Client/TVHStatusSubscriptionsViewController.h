//
//  TVHStatusSubscriptionsViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHStatusSubscriptionsStore.h"
#import "TVHAdaptersStore.h"

@interface TVHStatusSubscriptionsViewController : UITableViewController <TVHStatusSubscriptionsDelegate, TVHAdaptersDelegate>
- (IBAction)toggleStatusRefreshing:(UIBarButtonItem *)sender;

@end
