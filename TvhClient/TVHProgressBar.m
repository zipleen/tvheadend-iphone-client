//
//  ChromeProgressBar.m
//  ChromeProgressBar
//
//  Created by Mario Nguyen on 01/12/11.
//  Copyright (c) 2012 Mario Nguyen. All rights reserved.
//

#import "TVHProgressBar.h"

@implementation TVHProgressBar

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect progressRect = rect;
    progressRect.size.width *= [self progress];
    
    //Fill color
    CGContextSetFillColorWithColor(ctx, [_tintColor CGColor]);
    CGContextFillRect(ctx, progressRect);
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ( self=[super initWithCoder: decoder] )
    {
        //self.frame = CGRectMake(0,0,100,4);
        _tintColor = PROGRESS_BAR_PLAYBACK;
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        
        NSArray *subViews = self.subviews;
        for(UIView *view in subViews)
        {
            [view removeFromSuperview];
        }
    }
    return self;
}

@end