//
//  TVHMainSplitViewController.m
//  TvhClient
//
//  Created by zipleen on 4/29/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannelSplitViewController.h"

@interface TVHChannelSplitViewController ()

@end

@implementation TVHChannelSplitViewController

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
    self.delegate = self;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

@end
