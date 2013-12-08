//
//  TVHErrorNotice.h
//  TvhClient
//
//  Created by Luis Fernandes on 3/29/13.
//  Copyright (c) 2013 Luis Fernandes. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@interface TVHShowNotice : NSObject
+ (void)errorNoticeInView:(UIView*)view title:(NSString*)title message:(NSString*)message;
+ (void)successNoticeInView:(UIView *)view title:(NSString *)title;
@end
