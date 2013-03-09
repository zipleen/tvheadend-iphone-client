//
//  TVHJsonClient.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "AFHTTPClient.h"

@interface TVHJsonClient : AFHTTPClient
+ (TVHJsonClient*)sharedInstance;
- (void)setUsername:(NSString *)username password:(NSString *)password;

+ (NSDictionary*)convertFromJsonToObject:(NSData*)responseData error:(NSError*)error;
@end
