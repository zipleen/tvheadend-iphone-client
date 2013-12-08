//
//  TVHHelper.h
//  TvhClient
//
//  Created by Luis Fernandes on 7/2/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@interface UIView (UIViewWithFileSize)
+ (UIView*)TVHClosestParent:(NSString*)type ofView:(UIView*)view;
@end
