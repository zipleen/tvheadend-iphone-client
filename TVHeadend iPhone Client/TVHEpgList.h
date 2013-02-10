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

@protocol TVHEpgListDelegate <NSObject>
- (void) didLoadEpg;
@end

@interface TVHEpgList : NSObject
+ (id)sharedInstance;
- (void)fetchEpgList;
- (NSArray*)getEpgList;
- (void)setDelegate:(id <TVHEpgListDelegate>)delegate;
@end
