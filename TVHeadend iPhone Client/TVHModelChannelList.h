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

@protocol TVHModelChannelListDelegate <NSObject>

-(void) didLoadChannels;
@end

@interface TVHModelChannelList : AFHTTPClient 

+ (id)sharedInstance;

- (void)startGetTestData;

- (TVHChannel *) objectAtIndex:(int) row;
- (int) count;
- (void)setDelegate:(id <TVHModelChannelListDelegate>)delegate;

@end
