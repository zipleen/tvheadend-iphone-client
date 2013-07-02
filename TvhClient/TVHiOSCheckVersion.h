//
//  TVHiOSCheckVersion.h
//  TvhClient
//
//  Created by zipleen on 7/2/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

NSUInteger DeviceSystemMajorVersion();
#define DEVICE_HAS_IOS7 (DeviceSystemMajorVersion() >= 7)