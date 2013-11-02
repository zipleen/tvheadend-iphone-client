//
//  TVHPlayStream.h
//  TvhClient
//
//  Created by zipleen on 26/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHPlayStreamDelegate.h"

@interface TVHPlayStream : NSObject
+ (id)sharedInstance;
- (NSArray*)arrayOfAvailablePrograms;
- (BOOL)isTranscodingCapable;
- (NSString*)stringTranscodeUrl:(NSString*)url;
- (NSString*)stringTranscodeUrlInternalFormat:(NSString*)url;
- (BOOL)playStreamIn:(NSString*)program forObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding;
@end
