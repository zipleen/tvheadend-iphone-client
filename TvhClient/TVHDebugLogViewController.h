//
//  TVHDebugLogViewController.h
//  TvhClient
//
//  Created by zipleen on 09/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TVHLogStore.h"

@interface TVHDebugLogViewController : UITableViewController <TVHLogDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *debugButton;
- (IBAction)debugButton:(UIBarButtonItem *)sender;
- (IBAction)clearLog:(id)sender;

@end
