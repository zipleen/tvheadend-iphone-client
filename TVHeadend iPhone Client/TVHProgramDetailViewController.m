//
//  TVHProgramDetailViewController.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHProgramDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

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
    
    // shadown
    self.programImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.programImage.layer.shadowOffset = CGSizeMake(0, 2);
    self.programImage.layer.shadowOpacity = 0.7f;
    self.programImage.layer.shadowRadius = 1.5;
    self.programImage.clipsToBounds = NO;
    
    
    [self.record setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0] forState:UIControlStateNormal];
    
    
    /*[self.programImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.channel.imageUrl]] placeholderImage:[UIImage imageNamed:@"tv.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"Your image request succeeded!");
        self.programImage.image = [self imageWithShadow:image BlurSize:5.0f];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Your image request failed...");
    }];*/
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
    [self setRecord:nil];
    [super viewDidUnload];
}


- (IBAction)addRecordToTVHeadend:(id)sender {
    
}

- (IBAction)playStream:(id)sender {
    
}

@end
