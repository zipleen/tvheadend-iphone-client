//
//  TVHPlayStreamHelpController.m
//  TvhClient
//
//  Created by zipleen on 05/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHPlayStreamHelpController.h"
#import "KxMovieViewController.h"

@interface TVHPlayStreamHelpController() <UIActionSheetDelegate>
@property (weak, nonatomic) TVHChannel *channel;
@property (weak, nonatomic) UIViewController *vc;
@end

@implementation TVHPlayStreamHelpController

- (void)playStream:(UIBarButtonItem*)sender withChannel:(TVHChannel*)channel withVC:(UIViewController*)vc {
    self.channel = channel;
    self.vc = vc;
    
    NSString *actionSheetTitle = NSLocalizedString(@"Play Stream Options", nil);
    NSString *copy = NSLocalizedString(@"Copy to Clipboard", nil);
    NSString *buzz = @"Buzz Player";
    NSString *good = @"GoodPlayer";
    NSString *oplayer = @"Oplayer";
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    NSString *stream = NSLocalizedString(@"Stream Channel", nil);
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:stream
                                  otherButtonTitles:copy, buzz, good, oplayer, nil];
    //[actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:NSLocalizedString(@"Copy to Clipboard", nil)]) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:[self.channel streamURL]];
    }
    if ([buttonTitle isEqualToString:@"Buzz Player"]) {
        NSString *url = [NSString stringWithFormat:@"buzzplayer://%@", [self.channel streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:@"GoodPlayer"]) {
        NSString *url = [NSString stringWithFormat:@"goodplayer://%@", [self.channel streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:@"Oplayer"]) {
        NSString *url = [NSString stringWithFormat:@"oplayer://%@", [self.channel streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Stream Channel", nil)]) {
        NSString *url = [NSString stringWithFormat:@"%@?mux=pass", [self.channel streamURL] ];
        [self streamChannel:url];
    }
    
}

- (void)streamChannel:(NSString*) path {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // increase buffering for .wmv, it solves problem with delaying audio frames
    //if ([path.pathExtension isEqualToString:@"wmv"])
    // //   parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
    
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    // disable buffering
    // parameters[KxMovieParameterMinBufferedDuration] = @(0.0f);
    
    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:path
                                                                               parameters:parameters];
    [self.vc presentViewController:vc animated:YES completion:nil];
    //[self.navigationController pushViewController:vc animated:YES];
}

@end
