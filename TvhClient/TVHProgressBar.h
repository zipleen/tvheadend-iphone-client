//
//  ChromeProgressBar.h
//  TvhClient
//
//  Created by Mario Nguyen on 01/12/11.
//  Copyright (c) 2012 Mario Nguyen. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define PROGRESS_BAR_PLAYBACK [UIColor colorWithRed:0.3 green:0.6 blue:0.9 alpha:1]
#define PROGRESS_BAR_NEAR_END_PLAYBACK [UIColor colorWithRed:0.445 green:0 blue:0.632 alpha:1]
#define PROGRESS_BAR_RECORDING [UIColor colorWithRed:1 green:0 blue:0 alpha:1]

@class UIProgressView;

@interface TVHProgressBar : UIProgressView
@property (nonatomic, strong) UIColor *tintColor;
- (id)initWithCoder:(NSCoder *)decoder;

@end