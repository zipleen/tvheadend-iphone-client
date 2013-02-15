//
//  tvhclientChannelListViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/2/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHChannelStore.h"

@interface TVHChannelStoreViewController : UITableViewController <TVHChannelStoreDelegate>
@property (nonatomic) NSInteger filterTagId;
@end
