//
//  TVHPlayStreamHelpController.m
//  TvhClient
//
//  Created by zipleen on 05/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHPlayStreamHelpController.h"
#import "TVHNativeMoviePlayerViewController.h"
#import "TVHPlayStream.h"

@interface TVHPlayStreamHelpController() <UIActionSheetDelegate> {
    UIActionSheet *myActionSheet;
    BOOL transcodingEnabled;
}
@property (weak, nonatomic) id<TVHPlayStreamDelegate> streamObject;
@property (weak, nonatomic) UIStoryboard *storyboard;
@property (weak, nonatomic) UIViewController *vc;
@property (weak, nonatomic) UIBarButtonItem *sender;
@property (weak, nonatomic) TVHPlayStream *playStreamModal;
@end

@implementation TVHPlayStreamHelpController

- (id)init {
    self = [super init];
    if (self) {
        self.playStreamModal = [TVHPlayStream sharedInstance];
    }
    return self;
}

- (void)showTranscodeMenu:(UIBarButtonItem*)sender withVC:(UIViewController*)vc withActionSheet:(NSString*)actionTitle {
    transcodingEnabled = YES;
    [self showMenu:sender withVC:vc withActionSheet:actionTitle];
}

- (void)showMenu:(UIBarButtonItem*)sender withVC:(UIViewController*)vc withActionSheet:(NSString*)actionTitle {
    int countOfItems = 0;
    NSString *copy = NSLocalizedString(@"Copy to Clipboard", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *transcode;
    if ( transcodingEnabled ) {
        transcode = NSLocalizedString(@"Internal Player", nil);
    } else {
        transcode = NSLocalizedString(@"Transcode", nil);
    }

    [self dismissActionSheet];
    myActionSheet = [[UIActionSheet alloc] init];
    [myActionSheet setTitle:actionTitle];
    [myActionSheet setDelegate:self];
    
    if ( [self.playStreamModal isTranscodingCapable] ) {
        [myActionSheet addButtonWithTitle:transcode];
        [myActionSheet setDestructiveButtonIndex:countOfItems];
        countOfItems++;
    }
    
    [myActionSheet addButtonWithTitle:copy];
    countOfItems++;
    NSArray *available = [self.playStreamModal arrayOfAvailablePrograms];
    countOfItems += [available count];
    for( NSString *title in available )  {
        [myActionSheet addButtonWithTitle:title];
    }
    [myActionSheet setCancelButtonIndex:countOfItems];
    [myActionSheet addButtonWithTitle:cancel];
    
    [myActionSheet showFromBarButtonItem:sender animated:YES];

}

- (void)playStream:(UIBarButtonItem*)sender withChannel:(id<TVHPlayStreamDelegate>)channel withVC:(UIViewController*)vc  {
    self.streamObject = channel;
    self.vc = vc;
    self.sender = sender;
    transcodingEnabled = NO;
    [self showMenu:sender withVC:vc withActionSheet:NSLocalizedString(@"Stream Channel", nil)];
}

- (void)playDvr:(UIBarButtonItem*)sender withDvrItem:(id<TVHPlayStreamDelegate>)dvrItem withVC:(UIViewController*)vc {
    self.streamObject = dvrItem;
    self.vc = vc;
    self.sender = sender;
    transcodingEnabled = NO;
    [self showMenu:sender withVC:vc withActionSheet:NSLocalizedString(@"Play Dvr File", nil)];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSString *streamUrl, *streamUrlInternal;
    
    // transcoding changed the URL structure, otherwise get the direct url
    if ( transcodingEnabled ) {
        streamUrl = [self.playStreamModal stringTranscodeUrl:[self.streamObject streamURL]];
        streamUrlInternal = [self.playStreamModal stringTranscodeUrlInternalFormat:[self.streamObject playlistStreamURL]];
    } else {
        streamUrl = [self.streamObject streamURL];
    }
    
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Copy to Clipboard", nil)] ) {
        if ( streamUrl ) {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:streamUrl];
        }
    }
    
    NSURL *myURL = [self.playStreamModal URLforProgramWithName:buttonTitle forURL:streamUrl];
    if ( myURL ) {
        [[UIApplication sharedApplication] openURL:myURL];
        return ;
    }
    
    // transcode will call this menu again with the transcoding setting turned on
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Transcode", nil)] ) {
        [self dismissActionSheet];
        [self showTranscodeMenu:self.sender withVC:self.vc withActionSheet:NSLocalizedString(@"Playback Transcode Stream", nil)];
    }
    
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Internal Player", nil)] ) {
        [self streamNativeUrl:streamUrlInternal];
    }
}

- (void)dismissActionSheet {
    if ( myActionSheet ) {
        [myActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        myActionSheet = nil;
    }
}

- (void)streamNativeUrl:(NSString*)url {
    TVHNativeMoviePlayerViewController *moviePlayer = [[TVHNativeMoviePlayerViewController alloc] init];
    moviePlayer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.vc presentViewController:moviePlayer animated:YES completion:^{
        [moviePlayer playStream:url];
    }];
    
}

@end
