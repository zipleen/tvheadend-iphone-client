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

@class UIProgressView;

@interface TVHProgressBar : UIProgressView
@property (nonatomic, strong) UIColor *tintColor;
- (TVHProgressBar *)initWithFrame:(CGRect)frame;

@end