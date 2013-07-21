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
#import "TVHSettings.h"
#import "TVHNativeMoviePlayerViewController.h"

#define TVH_PROGRAMS @{@"VLC":@"vlc", @"Oplayer":@"oplayer", @"Buzz Player":@"buzzplayer", @"GoodPlayer":@"goodplayer", @"Ace Player":@"aceplayer" }
#define TVHS_TVHEADEND_STREAM_URL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS&mux=mpegts"

@interface TVHPlayStreamHelpController() <UIActionSheetDelegate> {
    UIActionSheet *myActionSheet;
}
@property (weak, nonatomic) id<TVHPlayStreamDelegate> streamObject;
@property (weak, nonatomic) UIStoryboard *storyboard;
@property (weak, nonatomic) UIViewController *vc;
@end

@implementation TVHPlayStreamHelpController

- (NSURL*)urlForSchema:(NSString*)schema withURL:(NSString*)url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", schema, url]];
}

- (NSArray*)arrayOfAvailablePrograms {
    NSMutableArray *available = [[NSMutableArray alloc] init];
    for (NSString* key in TVH_PROGRAMS) {
        NSString *urlTarget = [TVH_PROGRAMS objectForKey:key];
        NSURL *url = [self urlForSchema:urlTarget withURL:nil];
        if( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [available addObject:key];
        }
    }
    
    // custom
    NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
    if( [customPrefix length] > 0 ) {
        NSURL *url = [self urlForSchema:customPrefix withURL:nil];
        if( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [available addObject:NSLocalizedString(@"Custom Player", nil)];
        }
    }
    return [available copy];
}

- (void)showMenu:(UIBarButtonItem*)sender withVC:(UIViewController*)vc withActionSheet:(NSString*)actionTitle {
    int countOfItems = 0;
    NSString *actionSheetTitle = NSLocalizedString(@"Playback", nil);
    NSString *copy = NSLocalizedString(@"Copy to Clipboard", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *transcode = NSLocalizedString(@"Transcode", nil);

    [self dismissActionSheet];
    myActionSheet = [[UIActionSheet alloc] init];
    [myActionSheet setTitle:actionSheetTitle];
    [myActionSheet setDelegate:self];

    if ( [self.streamObject transcodeStreamURL] ) {
        [myActionSheet addButtonWithTitle:transcode];
        [myActionSheet setDestructiveButtonIndex:countOfItems];
        countOfItems++;
    }
    
    [myActionSheet addButtonWithTitle:copy];
    countOfItems++;
    NSArray *available = [self arrayOfAvailablePrograms];
    countOfItems += [available count];
    for( NSString *title in available )  {
        [myActionSheet addButtonWithTitle:title];
    }
    [myActionSheet setCancelButtonIndex:countOfItems];
    [myActionSheet addButtonWithTitle:cancel];
    
    //[actionSheet showFromToolbar:self.navigationController.toolbar];
    [myActionSheet showFromBarButtonItem:sender animated:YES];

}

- (void)playStream:(UIBarButtonItem*)sender withChannel:(id<TVHPlayStreamDelegate>)channel withVC:(UIViewController*)vc  {
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
        NSString *streamUrl = [self.streamObject streamURL];
        if ( streamUrl ) {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:streamUrl];
        }
    }
    
    NSString *prefix = [TVH_PROGRAMS objectForKey:buttonTitle];
    if ( prefix ) {
        NSURL *myURL = [self urlForSchema:prefix withURL:[self.streamObject streamURL]];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Custom Player", nil)]) {
        NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
        NSString *url = [NSString stringWithFormat:@"%@://%@", customPrefix, [self.streamObject streamURL] ];
        NSURL *myURL = [NSURL URLWithString:url ];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Transcode", nil)]) {
        [self streamNativeUrl: [self stringTranscodeUrl: [self.streamObject transcodeStreamURL] ] ];
    }
}

- (void)dismissActionSheet {
    if ( myActionSheet ) {
        [myActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        myActionSheet = nil;
    }
}

- (NSString*)stringTranscodeUrl:(NSString*)url {
    TVHSettings *settings = [TVHSettings sharedInstance];
    return [url stringByAppendingFormat:TVHS_TVHEADEND_STREAM_URL, [settings transcodeResolution]];
}

- (void)streamNativeUrl:(NSString*)url {
    TVHNativeMoviePlayerViewController *moviePlayer = [[TVHNativeMoviePlayerViewController alloc] init];
    moviePlayer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.vc presentViewController:moviePlayer animated:YES completion:^{
        [moviePlayer playStream:url];
    }];
    
}

@end
