//
//  TVHEpgList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"
#import "AFNetworking.h"

@class TVHEpgList;
@protocol TVHEpgListDelegate <NSObject>
- (void) didLoadEpg:(TVHEpgList*)epgList;
@end

@interface TVHEpgList : NSObject
+ (id)sharedInstance;
- (void)fetchEpgList;
- (NSArray*)getEpgList;
- (void)setDelegate:(id <TVHEpgListDelegate>)delegate;
@end
