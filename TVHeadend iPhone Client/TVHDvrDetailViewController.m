//
//  TVHDvrDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 01/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDvrDetailViewController.h"

@interface TVHDvrDetailViewController ()

@end

@implementation TVHDvrDetailViewController

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
	self.titleLabel.text = self.dvrItem.title;
    self.description.text = self.dvrItem.description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitle:nil];
    [self setDescription:nil];
    [self setTitleLabel:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}
@end
