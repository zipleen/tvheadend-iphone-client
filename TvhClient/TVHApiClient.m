//
//  TVHApiClient.m
//  TvhClient
//
//  Created by Luis Fernandes on 03/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHApiClient.h"

@interface TVHApiClient()
@property (weak, nonatomic) TVHJsonClient *jsonClient;
@end

@implementation TVHApiClient

- (id)init
{
    [NSException raise:@"Invalid Init" format:@"TVHApiClient needs JsonClient to work"];
    return nil;
}

- (id)initWithClient:(TVHJsonClient*)jsonClient {
    NSParameterAssert(jsonClient);
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
    } else if ( [[object apiMethod] isEqualToString:@"GET"] ) {
        [self.jsonClient getPath:[object apiPath]
                      parameters:[object apiParameters]
                         success:success
                         failure:failure];
    }
}

@end
