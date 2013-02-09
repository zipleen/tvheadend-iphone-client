//
//  ModelChannelList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"
#import "AFNetworking.h"

@protocol TVHChannelListDelegate <NSObject>

-(void) didLoadChannels;
-(void) didErrorLoading;
@end

@interface TVHChannelList : AFHTTPClient 

+ (id)sharedInstance;
- (void)fetchChannelList;

- (TVHChannel *) objectAtIndex:(int) row;
- (int) count;
- (void)setDelegate:(id <TVHChannelListDelegate>)delegate;

@end
