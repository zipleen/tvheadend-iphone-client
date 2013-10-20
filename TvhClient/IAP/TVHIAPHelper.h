//
//  RageIAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "IAPHelper.h"
#define IAP_PICS @{@"com.zipleen.TvhClient.1thanksllama":@"iap_lhama", @"com.zipleen.TvhClient.2thankssloth":@"iap_sloth", @"com.zipleen.TvhClient.3thankswale":@"iap_whale"}

@interface TVHIAPHelper : IAPHelper

+ (TVHIAPHelper *)sharedInstance;

@end
