//
//  TVHJsonClient.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "AFHTTPClient.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface TVHNetworkActivityIndicatorManager : AFNetworkActivityIndicatorManager
@end

@interface TVHJsonClient : AFHTTPClient
@property (nonatomic, readonly) BOOL readyToUse;
- (void)setUsername:(NSString *)username password:(NSString *)password;

+ (NSDictionary*)convertFromJsonToObject:(NSData*)responseData error:(__autoreleasing NSError**)error;
+ (NSArray*)convertFromJsonToArray:(NSData*)responseData error:(__autoreleasing NSError**)error;
@end
