//
//  ModelChannelList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannelListViewController.h"
#import "Channel.h"
#import "AFNetworking.h"

@interface ModelChannelList : AFHTTPClient <NSURLConnectionDelegate>

+ (id)sharedInstance;

- (void)startGetTestData;

- (Channel *) objectAtIndex:(int) row;
- (int) count;
- (void) setDelegate: (TVHChannelListViewController*)sender;

@end
