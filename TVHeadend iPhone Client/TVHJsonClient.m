//
//  TVHJsonClient.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHJsonClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TVHSettings.h"
#import "AFJSONRequestOperation.h"
#import "SDURLCache.h"

@implementation TVHJsonClient

#pragma mark - Methods

- (void)setUsername:(NSString *)username password:(NSString *)password {
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
    /*
     // for future reference, MD5 DIGEST. tvheadend uses basic
    NSURLCredential *newCredential;
    newCredential = [NSURLCredential credentialWithUser:username
                                               password:password
                                            persistence:NSURLCredentialPersistenceForSession];
    [self setDefaultCredential:newCredential];
     */
}

#pragma mark - Initialization

- (id)init {
    TVHSettings *settings = [TVHSettings sharedInstance];
    self = [super initWithBaseURL:[settings baseURL]];
    if( !self ) {
        return nil;
    }
    
    NSString *username = [settings username];
    if( ![username isEqualToString:@""] ) {
        NSString *password = [settings password];
        [self setUsername:username password:password];
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    //[self setDefaultHeader:@"Accept" value:@"application/json"];
    //[self setParameterEncoding:AFJSONParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
                                                         diskCapacity:1024*1024*5 // 5MB disk cache
                                                             diskPath:[SDURLCache defaultCachePath]];
    [NSURLCache setSharedURLCache:urlCache];
    
    return self;
}


+ (TVHJsonClient*)sharedInstance {
    static TVHJsonClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHJsonClient alloc] init];
    });
    
    return __sharedInstance;
}
@end
