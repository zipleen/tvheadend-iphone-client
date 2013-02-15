//
//  TVHProgramDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHProgramDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface TVHProgramDetailViewController () <UIActionSheetDelegate>

@end

@implementation TVHProgramDetailViewController
@synthesize epg = _epg;
@synthesize channel = _channel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.programTitle.text = self.epg.title;
    self.programDescription.text = self.epg.description;
    [self.programImage setImageWithURL:[NSURL URLWithString:self.channel.imageUrl] placeholderImage:[UIImage imageNamed:@"tv.png"]];
    //self.programImage.image = [UIImage imageNamed:@"tv.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setProgramDescription:nil];
    [self setProgramTitle:nil];
    [self setProgramImage:nil];
    [super viewDidUnload];
}

- (IBAction)addRecordToTVHeadend:(id)sender {
    
}

@end
