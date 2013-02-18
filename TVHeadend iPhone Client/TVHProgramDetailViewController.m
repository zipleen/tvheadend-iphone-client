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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    self.time.text = [NSString stringWithFormat:@"%@ | %@", [dateFormatter stringFromDate:self.epg.start], [dateFormatter stringFromDate:self.epg.end]];
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
    [self setProgramDescription:nil];
    [self setTime:nil];
    self.epg = nil;
    self.channel = nil;
    [super viewDidUnload];
}

- (IBAction)addRecordToTVHeadend:(id)sender {
    
}

- (IBAction)playStream:(id)sender {
    
}

@end
