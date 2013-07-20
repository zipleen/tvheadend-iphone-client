//
//  TVHErrorNotice.m
//  TvhClient
//
//  Created by zipleen on 3/29/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
    [notice setFloating:YES];
    //[notice setSticky:true];
    [notice show];
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"uiAction"
                                                    withAction:@"noticeScreens"
                                                     withLabel:@"error"
                                                     withValue:[NSNumber numberWithInt:0]];
#endif
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
