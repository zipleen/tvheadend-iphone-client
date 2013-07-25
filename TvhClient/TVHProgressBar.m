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

- (TVHProgressBar *)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
        //set bar color
        _tintColor = [UIColor colorWithRed:51.0f/255.0f green:153.0f/255.0f blue:255.0f/255.0f alpha:1];
		self.progress = 0;
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
	}
    
	return self;
}

@end