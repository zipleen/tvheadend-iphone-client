//
//  TVHEpg.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"

@interface TVHEpg : NSObject
@property (nonatomic) NSInteger channelId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDate *start;
@property (nonatomic, strong) NSDate *end;
@property (nonatomic) NSInteger duration;

- (void) setStartFromInteger:(NSInteger)start;
- (void) setEndFromInteger:(NSInteger)end;
- (float) progress;
@end
