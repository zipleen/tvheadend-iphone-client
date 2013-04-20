//
//  TVHSupportMeViewController.h
//  TvhClient
//
//  Created by zipleen on 4/19/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"

@interface TVHSupportMeViewController : UIViewController <ADBannerViewDelegate, GADBannerViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ADBannerView *bannerView;
@property (nonatomic, strong) GADBannerView *admobBannerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)buyRemoveAd:(UIButton *)sender;
- (IBAction)restorePurchase:(UIBarButtonItem *)sender;
@end
