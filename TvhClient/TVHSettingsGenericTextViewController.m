//
//  TVHSettingsGenericTextViewController.m
//  TvhClient
//
//  Created by zipleen on 3/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHSettingsGenericTextViewController.h"

@interface TVHSettingsGenericTextViewController ()

@end

@implementation TVHSettingsGenericTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeLink error:nil];
    NSURL *url;
    if ( [detector numberOfMatchesInString:self.url options:0 range:NSMakeRange(0, [self.url length])] > 0 ) {
        url = [NSURL URLWithString:self.url];
        self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        url = [NSURL fileURLWithPath:self.url];
        self.navigationController.navigationItem.rightBarButtonItem.enabled = YES;
    }
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

- (IBAction)openInSafari:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
}
@end
