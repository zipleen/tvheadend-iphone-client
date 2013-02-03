//
//  ModelChannelList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tvhclientChannelListViewController.h"

@interface ModelChannelList : NSObject <NSURLConnectionDelegate>

- (void)startGetTestData;

- (NSString *) objectAtIndex:(int) row;
- (int) count;
- (void) setDelegate: (tvhclientChannelListViewController*)sender;

@end
