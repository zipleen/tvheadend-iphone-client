//
//  TVHNativeMoviePlayerViewController.m
//  TvhClient
//
//  Created by zipleen on 7/20/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHNativeMoviePlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

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
