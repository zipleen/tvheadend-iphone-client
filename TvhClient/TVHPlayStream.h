//
//  TVHPlayStream.h
//  TvhClient
//
//  Created by Luis Fernandes on 26/10/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHPlayStreamDelegate.h"

@interface TVHPlayStream : NSObject
+ (id)sharedInstance;
+ (NSString*)streamUrlFromObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding;
+ (NSString*)stringTranscodeUrl:(NSString*)url;
+ (NSString*)stringTranscodeUrlInternalFormat:(NSString*)url;

- (NSArray*)arrayOfAvailablePrograms;
- (BOOL)isTranscodingCapable;
- (BOOL)playStreamIn:(NSString*)program forObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding;
@end
