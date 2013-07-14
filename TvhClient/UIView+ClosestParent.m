//
//  TVHHelper.m
//  TvhClient
//
//  Created by zipleen on 7/2/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "UIView+ClosestParent.h"

@implementation UIView (UIViewWithFileSize)
+ (UIView*)TVHClosestParent:(NSString*)type ofView:(UIView*)view {
    while ( view != nil ) {
        if ( [view isKindOfClass:NSClassFromString(type)] ) {
            return view;
        }
        view = view.superview;
    }
    return nil;
}
@end
