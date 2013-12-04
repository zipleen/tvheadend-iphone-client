//
//  TVHApiClient.m
//  TvhClient
//
//  Created by zipleen on 03/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHApiClient.h"

@interface TVHApiClient()
@property (weak, nonatomic) TVHJsonClient *jsonClient;
@end

@implementation TVHApiClient

- (id)initWithClient:(TVHJsonClient*)jsonClient {
    self = [super init];
    if (!self) return nil;
    
    self.jsonClient = jsonClient;
    return self;
}

- (void)doApiCall:(id <TVHApiClientDelegate>)object
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    if ( [[object apiMethod] isEqualToString:@"POST"] ) {
        [self.jsonClient postPath:[object apiPath]
                       parameters:[object apiParameters] success:success
                          failure:failure];
    } else {
        [self.jsonClient getPath:[object apiPath]
                      parameters:[object apiParameters]
                         success:success
                         failure:failure];
    }
}

@end
