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

@class TVHEpgStore;
@protocol TVHEpgStoreDelegate <NSObject>
- (void) didLoadEpg:(TVHEpgStore*)epgList;
@optional
-(void) didErrorLoadingEpgStore:(NSError*)error;
@end

@interface TVHEpgStore : NSObject
@property (nonatomic, strong) NSString* filterToChannelName;
+ (id)sharedInstance;
- (void)downloadEpgList;
- (NSArray*)getEpgList;
- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate;
@end
