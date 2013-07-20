//
//  TVHImageCache.h
//  TvhClient
//
//  Created by zipleen on 4/16/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"

@interface TVHImageCache : NSObject <SDWebImageManagerDelegate>
+ (UIImage*)resizeImage:(UIImage*)image;
@end
