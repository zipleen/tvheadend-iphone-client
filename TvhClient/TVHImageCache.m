//
//  TVHImageCache.m
//  TvhClient
//
//  Created by Luis Fernandes on 4/16/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHImageCache.h"

@implementation TVHImageCache

+ (CGSize)sizeFromImage:(UIImage*)image withContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds {
    CGFloat horizontalRatio = bounds.width / image.size.width;
    CGFloat verticalRatio = bounds.height / image.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", (int)contentMode];
    }
    
    CGSize newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
    return newSize;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
    return [TVHImageCache resizeImage:image];
}

+ (UIImage*)resizeImage:(UIImage*)image {
    // I tried working with this http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/
    // but it didn't work quite well..
    CGSize newSize = [TVHImageCache sizeFromImage:image withContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(120, 100)];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
