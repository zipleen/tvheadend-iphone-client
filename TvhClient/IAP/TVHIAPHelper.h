//
//  RageIAPHelper.h
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "IAPHelper.h"
#define IAP_PICS @{@"com.zipleen.TvhClient.1thanksllama":@"iap_lhama.jpg", @"com.zipleen.TvhClient.2thankssloth":@"iap_sloth.jpg", @"com.zipleen.TvhClient.3thankswale":@"iap_whale.jpg"}

@interface TVHIAPHelper : IAPHelper

+ (TVHIAPHelper *)sharedInstance;

@end
