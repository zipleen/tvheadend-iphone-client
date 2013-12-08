//
//  TVHWebLogViewController.h
//  TvhClient
//
//  Created by Luis Fernandes on 27/10/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
