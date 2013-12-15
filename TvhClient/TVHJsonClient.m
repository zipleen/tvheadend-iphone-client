//
//  TVHJsonClient.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/22/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHServerSettings.h"
#import "TVHJsonClient.h"
#import "AFJSONRequestOperation.h"
#import "SSHWrapper.h"
#import "TVHImageCache.h"

@implementation TVHNetworkActivityIndicatorManager

- (void)networkingOperationDidStart:(NSNotification *)notification {
    AFURLConnectionOperation *connectionOperation = [notification object];
    if (connectionOperation.request.URL) {
        if ( ! [connectionOperation.request.URL.path isEqualToString:@"/comet/poll"] ) {
            [self incrementActivityCount];
        }
    }
}

- (void)networkingOperationDidFinish:(NSNotification *)notification {
    AFURLConnectionOperation *connectionOperation = [notification object];
    if (connectionOperation.request.URL) {
        if ( ! [connectionOperation.request.URL.path isEqualToString:@"/comet/poll"] ) {
            [self decrementActivityCount];
        }
    }
}

@end

@implementation TVHJsonClient {
    SSHWrapper *sshPortForwardWrapper;
    TVHImageCache *imageCacheTransform;
}

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

- (id)init
{
    [NSException raise:@"Invalid Init" format:@"JsonClient needs ServerSettings to work"];
    return nil;
}

- (id)initWithSettings:(TVHServerSettings *)settings {
    NSParameterAssert(settings);
    
    // setup port forward
    if ( [settings.sshPortForwardHost length] > 0 ) {
        [self setupPortForwardToHost:settings.sshPortForwardHost
                           onSSHPort:[settings.sshPortForwardPort intValue]
                        withUsername:settings.sshPortForwardUsername
                        withPassword:settings.sshPortForwardPassword
                         onLocalPort:[TVHS_SSH_PF_LOCAL_PORT intValue]
                              toHost:settings.ip
                        onRemotePort:[settings.port intValue]
         ];
        _readyToUse = NO;
    } else {
        _readyToUse = YES;
    }
    
    self = [super initWithBaseURL:settings.baseURL];
    if( !self ) {
        return nil;
    }
    
    if( [settings.username length] > 0 ) {
        [self setUsername:settings.username password:settings.password];
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    //[self setDefaultHeader:@"Accept" value:@"application/json"];
    //[self setParameterEncoding:AFJSONParameterEncoding];
    
    [[TVHNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    //imageCacheTransform = [[TVHImageCache alloc] init];
    //SDWebImageManager.sharedManager.delegate = imageCacheTransform;
    return self;
}

- (void)dealloc {
    [[self operationQueue] cancelAllOperations];
    [self stopPortForward];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark AFHTTPClient methods

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    if ( ! [self readyToUse] ) {
        return;
    }
    return [super getPath:path parameters:parameters success:success failure:failure];
}


- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    if ( ! [self readyToUse] ) {
        return;
    }
    return [super postPath:path parameters:parameters success:success failure:failure];
}


#pragma mark JsonHelper

+ (NSDictionary*)convertFromJsonToObjectFixUtf8:(NSData*)responseData error:(__autoreleasing NSError**)error {
    
    NSMutableData *FileData = [NSMutableData dataWithLength:[responseData length]];
    for (int i = 0; i < [responseData length]; ++i)
    {
        char *a = &((char*)[responseData bytes])[i];
        if( ((int)*a >0 && (int)*a < 0x20)  ) {
            ((char*)[FileData mutableBytes])[i] = 0x20;
        } else {
            ((char*)[FileData mutableBytes])[i] = ((char*)[responseData bytes])[i];
        }
    }
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:FileData //1
                                                         options:kNilOptions
                                                           error:error];
    
    if( *error ) {
        NSLog(@"[JSON Error (2nd)]: %@ ", (*error).description);
        return nil;
    }
    
    return json;
}

+ (NSDictionary*)convertFromJsonToObject:(NSData*)responseData error:(__autoreleasing NSError**)error {
    NSError __autoreleasing *errorForThisMethod;
    if ( ! responseData ) {
        NSDictionary *errorDetail = @{NSLocalizedDescriptionKey: @"No data received"};
        if (error != NULL) {
            *error = [[NSError alloc] initWithDomain:@"No data received"
                                            code:-1
                                        userInfo:errorDetail];
        }
        return nil;
    }
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:&errorForThisMethod];
    
    if( errorForThisMethod ) {
        /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile"];
         [responseData writeToFile:appFile atomically:YES];
         NSLog(@"%@",documentsDirectory);
         */
#ifdef TESTING
        NSLog(@"[JSON Error (1st)]: %@", errorForThisMethod.description);
#endif
        return [self convertFromJsonToObjectFixUtf8:responseData error:error];
    }
    
    return json;
}

+ (NSArray*)convertFromJsonToArray:(NSData*)responseData error:(__autoreleasing NSError**)error {
    if ( ! responseData ) {
        NSDictionary *errorDetail = @{NSLocalizedDescriptionKey: @"No data received"};
        if (error != NULL) {
            *error = [[NSError alloc] initWithDomain:@"No data received"
                                                code:-1
                                            userInfo:errorDetail];
        }
        return nil;
    }
    NSArray* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions
                                                           error:error];
    
    return json;
}

#pragma mark SSH

- (void)setupPortForwardToHost:(NSString*)hostAddress
                     onSSHPort:(unsigned int)sshHostPort
                  withUsername:(NSString*)username
                  withPassword:(NSString*)password
                   onLocalPort:(unsigned int)localPort
                        toHost:(NSString*)remoteIp
                  onRemotePort:(unsigned int)remotePort  {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSError *error;
        sshPortForwardWrapper = [[SSHWrapper alloc] init];
        [sshPortForwardWrapper connectToHost:hostAddress port:sshHostPort user:username password:password error:error];
        if ( !error ) {
            _readyToUse = YES;
            [sshPortForwardWrapper setPortForwardFromPort:localPort toHost:remoteIp onPort:remotePort];
            _readyToUse = NO;
        } else {
            NSLog(@"erro ssh pf: %@", error.localizedDescription);
        }
    });
}

- (void)stopPortForward {
    if ( ! sshPortForwardWrapper ) {
        return ;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [sshPortForwardWrapper closeConnection];
        sshPortForwardWrapper = nil;
    });
}
@end
