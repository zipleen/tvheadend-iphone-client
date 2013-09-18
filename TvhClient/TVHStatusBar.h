//
//  TVHStatusBar.h
//  TvhClient
//
//  Created by zipleen on 9/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "WTStatusBar.h"

@interface TVHStatusBar : WTStatusBar

+ (void) clearStatusAnimated:(BOOL)animated;
+ (void) setStatusText:(NSString *)text timeout:(NSTimeInterval)timeout animated:(BOOL)animated;

@end
