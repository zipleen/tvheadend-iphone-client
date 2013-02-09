//
//  ModelChannelList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannelListViewController.h"
#import "TVHChannel.h"
#import "AFNetworking.h"

@interface TVHModelChannelList : AFHTTPClient <NSURLConnectionDelegate>

+ (id)sharedInstance;

- (void)startGetTestData;

- (TVHChannel *) objectAtIndex:(int) row;
- (int) count;
- (void) setDelegate: (TVHChannelListViewController*)sender;

@end
