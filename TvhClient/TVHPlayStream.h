//
//  TVHPlayStream.h
//  TvhClient
//
//  Created by zipleen on 26/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHPlayStream : NSObject
+ (id)sharedInstance;
- (NSArray*)arrayOfAvailablePrograms;
- (BOOL)isTranscodingCapable;
- (NSString*)stringTranscodeUrl:(NSString*)url;
- (NSString*)stringTranscodeUrlInternalFormat:(NSString*)url;
- (NSURL*)URLforProgramWithName:(NSString*)title forURL:(NSString*)streamUrl;
- (BOOL)playProgramWithName:(NSString*)title forURL:(NSString*)streamUrl;
@end
