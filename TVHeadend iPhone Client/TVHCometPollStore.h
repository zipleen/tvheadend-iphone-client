//
//  TVHCometPollStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/21/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "AFHTTPClient.h"

@interface TVHCometPollStore : AFHTTPClient
+ (id)sharedInstance;
- (void)fetchCometPollStatus;
@end
