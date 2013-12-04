//
//  TVHApiClient.h
//  TvhClient
//
//  Created by zipleen on 03/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHJsonClient.h"

@protocol TVHApiClientDelegate <NSObject>
- (NSDictionary*)apiParameters;
- (NSString*)apiMethod;
- (NSString*)apiPath;
@end

@interface TVHApiClient : NSObject
- (id)initWithClient:(TVHJsonClient*)jsonClient;
- (void)doApiCall:(id <TVHApiClientDelegate>)object
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
