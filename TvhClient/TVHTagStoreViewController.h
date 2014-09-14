//
//  TVHTagListViewController.h
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <UIKit/UIKit.h>
#import "TVHTagStore.h"
#import "TVHTag.h"

@interface TVHTagStoreViewController : UITableViewController <TVHTagStoreDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *serverButton;
- (IBAction)changeServer:(id)sender;

@end
