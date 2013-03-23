//
//  TVHPlayStreamHelpController.m
//  TvhClient
//
//  Created by zipleen on 05/03/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHPlayStreamHelpController.h"
#import "TVHSettings.h"

//#define KXMOVIE
#ifdef KXMOVIE
#import "KxMovieViewController.h"
#endif

@interface TVHPlayStreamHelpController() <UIActionSheetDelegate>
@property (weak, nonatomic) id<TVHPlayStreamDelegate> streamObject;
@property (weak, nonatomic) UIViewController *vc;
@end

@implementation TVHPlayStreamHelpController

- (void)showMenu:(UIBarButtonItem*)sender withVC:(UIViewController*)vc withActionSheet:(NSString*)actionTitle{
    NSString *actionSheetTitle = NSLocalizedString(@"Playback", nil);
    NSString *copy = NSLocalizedString(@"Copy to Clipboard", nil);
    NSString *buzz = @"Buzz Player";
    NSString *good = @"GoodPlayer";
    NSString *oplayer = @"Oplayer";
    NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
    NSString *custom = NSLocalizedString(@"Custom Player", nil);
    NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
#ifdef KXMOVIE
    NSString *stream = NSLocalizedString(actionTitle, nil);
#endif
    UIActionSheet *actionSheet;
    if ( [customPrefix isEqualToString:@""] ) {
        actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
#ifdef KXMOVIE
                                  destructiveButtonTitle:stream
#else
                                  destructiveButtonTitle:nil
#endif
                                  otherButtonTitles:copy, buzz, good, oplayer, nil];
    } else {
        actionSheet = [[UIActionSheet alloc]
                               initWithTitle:actionSheetTitle
                               delegate:self
                               cancelButtonTitle:cancelTitle
#ifdef KXMOVIE
                               destructiveButtonTitle:stream
#else
                               destructiveButtonTitle:nil
#endif
                               otherButtonTitles:copy, buzz, good, oplayer, custom, nil];
    }
    
    //[actionSheet showFromToolbar:self.navigationController.toolbar];
    [actionSheet showFromBarButtonItem:sender animated:YES];

}

- (void)playStream:(UIBarButtonItem*)sender withChannel:(id<TVHPlayStreamDelegate>)channel withVC:(UIViewController*)vc {
    self.streamObject = channel;
    self.vc = vc;
    [self showMenu:sender withVC:vc withActionSheet:@"Stream Channel"];
}

- (void)playDvr:(UIBarButtonItem*)sender withDvrItem:(id<TVHPlayStreamDelegate>)dvrItem withVC:(UIViewController*)vc {
    self.streamObject = dvrItem;
    self.vc = vc;
    [self showMenu:sender withVC:vc withActionSheet:@"Play Dvr File"];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:NSLocalizedString(@"Copy to Clipboard", nil)]) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:[self.streamObject streamURL]];
    }
    if ([buttonTitle isEqualToString:@"Buzz Player"]) {
        NSString *url = [NSString stringWithFormat:@"buzzplayer://%@", [self.streamObject streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:@"GoodPlayer"]) {
        NSString *url = [NSString stringWithFormat:@"goodplayer://%@", [self.streamObject streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:@"Oplayer"]) {
        NSString *url = [NSString stringWithFormat:@"oplayer://%@", [self.streamObject streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Custom Player", nil)]) {
        NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
        NSString *url = [NSString stringWithFormat:@"%@://%@", customPrefix, [self.streamObject streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
#ifdef KXMOVIE
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Stream Channel", nil)]) {
        NSString *url = [NSString stringWithFormat:@"%@?mux=pass", [self.streamObject streamURL] ];
        [self streamChannel:url];
    }
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Play Dvr File", nil)]) {
        NSString *url = [NSString stringWithFormat:@"%@?mux=pass", [self.streamObject streamURL] ];
        [self streamChannel:url];
    }
#endif
}

#ifdef KXMOVIE
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
#endif

@end
