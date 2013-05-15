//
//  TVHMainSlidePanelViewController.m
//  TvhClient
//
//  Created by zipleen on 5/15/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHMainSlidePanelViewController.h"

@interface TVHMainSlidePanelViewController ()

@end

@implementation TVHMainSlidePanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) awakeFromNib
{
    self.leftFixedWidth = 250 * [[UIScreen mainScreen] scale];
    self.rightFixedWidth = 700;
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"leftMainMenu"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"channelSplitController"]];
    [self setRightPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"debugNavigationController"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
