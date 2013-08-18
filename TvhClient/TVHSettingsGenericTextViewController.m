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

@interface TVHSettingsGenericTextViewController () {
    BOOL isHttp;
}
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
    NSURL *url;
    if ( [[self.url substringToIndex:4] isEqualToString:@"http"] ) {
        url = [NSURL URLWithString:self.url];
        isHttp = YES;
        self.webView.scalesPageToFit = YES;
    } else {
        url = [NSURL fileURLWithPath:self.url];
        isHttp = NO;
    }
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView setDelegate:self];
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

- (IBAction)goBack:(id)sender {
    [self.webView goBack];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIBarButtonItem *addButton1;
    if ( [webView canGoBack] ) {
        addButton1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Go Back", @"")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(goBack:)];
    } else {
        if ( isHttp ) {
            addButton1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Open In Safari", @"")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(openInSafari:)];
        }
    }
    [self.navigationItem setRightBarButtonItem:addButton1];
}
@end
