//
//  TVHErrorNotice.m
//  TvhClient
//
//  Created by zipleen on 3/29/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHShowNotice.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"

@interface TVHShowNotice()

@end

@implementation TVHShowNotice
static WBErrorNoticeView *notice;
static WBSuccessNoticeView *success;

+ (void)errorNoticeInView:(UIView*)view title:(NSString*)title message:(NSString*)message {
    if ( notice && [notice isKindOfClass:[WBErrorNoticeView class]] ) {
        [notice setDelay:0];
        [notice dismissNotice];
        notice = nil;
    }
    notice = [WBErrorNoticeView errorNoticeInView:view title:title message:message];
    [notice setDelay:10];
    //[success setFloating:YES];
    //[notice setSticky:true];
    [notice show];
}

+ (void)successNoticeInView:(UIView *)view title:(NSString *)title {
    if ( success && [success isKindOfClass:[WBSuccessNoticeView class]] ) {
        [success setDelay:0];
        [success dismissNotice];
        success = nil;
    }
    success = [WBSuccessNoticeView successNoticeInView:view title:title];
    [success setFloating:YES];
    [success show];
}

@end
