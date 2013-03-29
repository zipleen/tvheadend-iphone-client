//
//  TVHErrorNotice.h
//  TvhClient
//
//  Created by zipleen on 3/29/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHShowNotice : NSObject
+ (void)errorNoticeInView:(UIView*)view title:(NSString*)title message:(NSString*)message;
+ (void)successNoticeInView:(UIView *)view title:(NSString *)title;
@end
