//
//  TVHiOSCheckVersion.m
//  TvhClient
//
//  Created by zipleen on 7/2/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHiOSCheckVersion.h"

// Sample code from iOS 7 Transistion Guide
// Loading Resources Conditionally

NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion]
                                       componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}
