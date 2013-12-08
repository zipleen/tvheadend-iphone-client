//
//  TVHNativeMoviePlayerViewController.m
//  TvhClient
//
//  Created by Luis Fernandes on 7/20/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHNativeMoviePlayerViewController.h"

@interface TVHNativeMoviePlayerViewController ()
@property (strong, nonatomic) MPMoviePlayerController *streamPlayer;
@end

@implementation TVHNativeMoviePlayerViewController

- (void)playStream:(NSString*)url
{
	NSURL *streamURL = [NSURL URLWithString:url];
    _streamPlayer = [[MPMoviePlayerController alloc] initWithContentURL:streamURL];
    [_streamPlayer setMovieSourceType:MPMovieSourceTypeStreaming];
    [self.streamPlayer prepareToPlay];
    
    [self.streamPlayer.view setFrame:self.view.bounds];
    self.streamPlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.streamPlayer.controlStyle = MPMovieControlStyleFullscreen;
    self.streamPlayer.shouldAutoplay = YES;
    [self.streamPlayer setFullscreen:YES animated:YES];
    
    self.streamPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.streamPlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    NSLog(@"[MoviePlayer] Going to play: %@", streamURL);
    [self.streamPlayer play];
}

- (void)moviePlayerDidFinish:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:nil];
    
    // to prevent a black screen on second play
    [self.streamPlayer stop];
    // to prevent flickering on second play
    //self.initialPlaybackTime = -1;
    
    [self.streamPlayer.view removeFromSuperview];
    self.streamPlayer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
