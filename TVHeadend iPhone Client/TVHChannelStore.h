//
//  ModelChannelList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"
#import "TVHEpgStore.h"
#import "AFNetworking.h"

@protocol TVHChannelStoreDelegate <NSObject>

-(void) didLoadChannels;
-(void) didErrorLoadingChannelStore:(NSError*)error;
@end

@interface TVHChannelStore : AFHTTPClient <TVHEpgStoreDelegate>

@property (nonatomic) NSInteger filterTag;
+ (id)sharedInstance;
- (void)fetchChannelList;
- (void)resetChannelStore;

- (TVHChannel *) objectAtIndex:(int) row;
- (int) count;
- (void)setDelegate:(id <TVHChannelStoreDelegate>)delegate;

@end
