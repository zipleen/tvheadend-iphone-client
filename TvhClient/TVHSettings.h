//
//  TVHSettings.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHSettings : NSObject
@property (nonatomic, strong, readonly) NSString *ip;
@property (nonatomic, strong, readonly) NSURL *baseURL;
+ (id)sharedInstance;
- (void)resetSettings;
- (NSString*)username;
- (NSString*)password;
- (NSTimeInterval)cacheTime;
@end
