//
//  TVHEpgList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"

@class TVHEpgStore;
@protocol TVHEpgStoreDelegate <NSObject>
- (void)didLoadEpg:(TVHEpgStore*)epgStore;
@optional
- (void)didErrorLoadingEpgStore:(NSError*)error;
@end

@interface TVHEpgStore : NSObject
@property (nonatomic, strong) NSString *filterToChannelName;
@property (nonatomic, strong) NSString *filterToProgramTitle;
+ (id)sharedInstance;
- (void)downloadEpgList;
- (NSArray*)getEpgList;
- (void)setDelegate:(id <TVHEpgStoreDelegate>)delegate;
@end
