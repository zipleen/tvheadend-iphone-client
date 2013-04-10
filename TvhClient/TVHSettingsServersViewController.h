//
//  TVHSettingsServersViewController.h
//  TvhClient
//
//  Created by zipleen on 3/21/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVHSettingsServersViewController : UITableViewController
- (IBAction)saveServer:(id)sender;
@property (nonatomic) NSInteger selectedServer;
@end
