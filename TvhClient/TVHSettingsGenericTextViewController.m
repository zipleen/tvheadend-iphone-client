//
//  TVHSettingsGenericTextViewController.m
//  TvhClient
//
//  Created by zipleen on 3/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
    self.genericText.text = self.displayText;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGenericText:nil];
    [super viewDidUnload];
}
@end
