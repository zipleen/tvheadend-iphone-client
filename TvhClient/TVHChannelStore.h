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

@protocol TVHChannelStoreDelegate <NSObject>

-(void) didLoadChannels;
-(void) didErrorLoadingChannelStore:(NSError*)error;
@end

@interface TVHChannelStore : NSObject <TVHEpgStoreDelegate>

@property (nonatomic) NSInteger filterTag;
+ (id)sharedInstance;
- (void)fetchChannelList;
- (void)resetChannelStore;

- (TVHChannel *)objectAtIndex:(int) row;
- (int)count;
- (void)setDelegate:(id <TVHChannelStoreDelegate>)delegate;
- (TVHChannel*)channelWithName:(NSString*) name;
- (TVHChannel*)channelWithId:(NSInteger) channelId;
- (NSArray*) getFilteredChannelList;
@end
