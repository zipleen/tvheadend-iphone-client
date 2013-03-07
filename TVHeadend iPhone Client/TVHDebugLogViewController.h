//
//  TVHDebugLogViewController.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 02/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVHDebugLogViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *debugLog;
@property (weak, nonatomic) IBOutlet UISwitch *switchPolling;
- (IBAction)switchPolling:(UISwitch *)sender;
@end
