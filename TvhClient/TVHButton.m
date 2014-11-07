//
//  TVHButton.m
//  TvhClient
//
//  Created by zipleen on 06/11/14.
//  Copyright (c) 2014 zipleen. All rights reserved.
//

#import "TVHButton.h"

@implementation TVHButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupColor];
    }
    return self;
}

- (void)setupColor {
    if ( DEVICE_HAS_IOS7 ) {
        UIColor *defaultTintColor = [UIColor blueColor];//[UIColor colorWithRed:0.041 green:0.375 blue:0.998 alpha:1.000];
        self.layer.borderWidth = 1;
        self.layer.borderColor = defaultTintColor.CGColor;
        self.layer.cornerRadius = 2;
        //self.layer.masksToBounds = YES;
        
        [self setTitleColor:defaultTintColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        UIImage *backGroundImage = [TVHButton createSolidColorImageWithColor:defaultTintColor
                                                                   andSize:self.bounds.size];
        [self setBackgroundImage:backGroundImage forState:UIControlStateHighlighted];
        
    } else {
        self.titleLabel.textColor = [UIColor grayColor];
        [self setBackgroundImage:[[UIImage imageNamed:@"nav-button.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"nav-button_selected.png"]  stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    }
}

+ (UIImage*)createSolidColorImageWithColor:(UIColor*)color andSize:(CGSize)size
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillRect(currentContext, fillRect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
