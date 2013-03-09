//
//  TVHDvrActions.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/28/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHDvrActions : NSObject
+ (void)addRecording:(NSInteger)eventId withConfigName:(NSString*)configName;
+ (void)cancelRecording:(NSInteger)eventId;
+ (void)deleteRecording:(NSInteger)eventId;
@end
