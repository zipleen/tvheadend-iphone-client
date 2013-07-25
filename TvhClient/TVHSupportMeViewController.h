//
//  TVHSupportMeViewController.h
//  TvhClient
//
//  Created by zipleen on 4/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVHSupportMeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)buyRemoveAd:(UIButton *)sender;
- (IBAction)restorePurchase:(UIBarButtonItem *)sender;
@end
