//
//  ModelChannelList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelChannelList : NSObject <NSURLConnectionDelegate>
- (NSArray *) getTestData;
- (void)startGetTestData;
@end
