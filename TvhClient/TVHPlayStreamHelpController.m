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
#import "TVHSingletonServer.h"

#define TVH_PROGRAMS @{@"VLC":@"vlc", @"Oplayer":@"oplayer", @"Buzz Player":@"buzzplayer", @"GoodPlayer":@"goodplayer", @"Ace Player":@"aceplayer" }
#define TVHS_TVHEADEND_STREAM_URL_INTERNAL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS&mux=mpegts"
#define TVHS_TVHEADEND_STREAM_URL @"?transcode=1&resolution=%@&vcodec=H264&acodec=AAC&scodec=PASS"

@interface TVHPlayStreamHelpController() <UIActionSheetDelegate> {
    UIActionSheet *myActionSheet;
    BOOL transcodingEnabled;
}
@property (weak, nonatomic) id<TVHPlayStreamDelegate> streamObject;
@property (weak, nonatomic) UIStoryboard *storyboard;
@property (weak, nonatomic) UIViewController *vc;
@property (weak, nonatomic) UIBarButtonItem *sender;
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
    
    TVHServer *tvhServer = [TVHSingletonServer sharedServerInstance];
    if ( [tvhServer isTranscodingCapable] ) {
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
    
    if ( transcodingEnabled ) {
        streamUrl = [self stringTranscodeUrl:[self.streamObject streamURL] withFormat:TVHS_TVHEADEND_STREAM_URL];
        streamUrlInternal = [self stringTranscodeUrl:[self.streamObject playlistStreamURL] withFormat:TVHS_TVHEADEND_STREAM_URL_INTERNAL];
    } else {
        streamUrl = [self.streamObject streamURL];
    }
    
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Copy to Clipboard", nil)] ) {
        if ( streamUrl ) {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:streamUrl];
        }
    }
    
    NSString *prefix = [TVH_PROGRAMS objectForKey:buttonTitle];
    if ( prefix ) {
        NSURL *myURL = [self urlForSchema:prefix withURL:streamUrl];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    if ( [buttonTitle isEqualToString:NSLocalizedString(@"Custom Player", nil)] ) {
        NSString *customPrefix = [[TVHSettings sharedInstance] customPrefix];
        NSString *url = [NSString stringWithFormat:@"%@://%@", customPrefix, streamUrl ];
        NSURL *myURL = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:myURL];
    }
    
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

- (NSString*)stringTranscodeUrl:(NSString*)url withFormat:(NSString*)format {
    TVHSettings *settings = [TVHSettings sharedInstance];
    return [url stringByAppendingFormat:format, [settings transcodeResolution]];
}

- (void)streamNativeUrl:(NSString*)url {
    TVHNativeMoviePlayerViewController *moviePlayer = [[TVHNativeMoviePlayerViewController alloc] init];
    moviePlayer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.vc presentViewController:moviePlayer animated:YES completion:^{
        [moviePlayer playStream:url];
    }];
    
}

@end
