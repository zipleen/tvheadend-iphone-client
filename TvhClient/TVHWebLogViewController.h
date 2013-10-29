//
//  TVHWebLogViewController.h
//  TvhClient
//
//  Created by zipleen on 27/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSplitViewController.h"

@interface TVHWebLogViewController : UIViewController <MGSplitViewControllerDelegate, UIWebViewDelegate>
@property (weak, nonatomic) MGSplitViewController *splitViewController;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)backButton:(id)sender;
- (IBAction)reloadButton:(id)sender;
- (IBAction)resizeButton:(id)sender;
@end
