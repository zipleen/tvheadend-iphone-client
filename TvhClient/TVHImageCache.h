//
//  TVHImageCache.h
//  TvhClient
//
//  Created by zipleen on 4/16/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImage/UIImageView+WebCache.h"

@interface TVHImageCache : NSObject <SDWebImageManagerDelegate>
+ (UIImage*)resizeImage:(UIImage*)image;
@end
