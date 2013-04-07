//
//  TVHJsonClient.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHJsonClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TVHSettings.h"
#import "AFJSONRequestOperation.h"
#import "SSHWrapper.h"
static TVHJsonClient *__jsonClient;

@implementation TVHJsonClient {
    SSHWrapper *sshPortForwardWrapper;
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

- (id)init {
    TVHSettings *settings = [TVHSettings sharedInstance];
    NSURL *baseUrl = [settings baseURL];
    if ( ! baseUrl ) {
        return nil;
    }
    
    // setup port forward
    if ( [[settings currentServerProperty:TVHS_SSH_PF_HOST] length] > 0 ) {
        [self setupPortForwardToHost:[settings currentServerProperty:TVHS_SSH_PF_HOST]
                           onSSHPort:[[settings currentServerProperty:TVHS_SSH_PF_PORT] intValue]
                        withUsername:[settings currentServerProperty:TVHS_SSH_PF_USERNAME]
                        withPassword:[settings currentServerProperty:TVHS_SSH_PF_PASSWORD]
                         onLocalPort:[TVHS_SSH_PF_LOCAL_PORT intValue]
                              toHost:[settings currentServerProperty:TVHS_IP_KEY]
                        onRemotePort:[[settings currentServerProperty:TVHS_PORT_KEY] intValue]
         ];
        _readyToUse = NO;
    } else {
        _readyToUse = YES;
    }
    
    self = [super initWithBaseURL:baseUrl];
    if( !self ) {
        return nil;
    }
    
    NSString *username = [settings username];
    if( [username length] > 0 ) {
        NSString *password = [settings password];
        [self setUsername:username password:password];
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    //[self setDefaultHeader:@"Accept" value:@"application/json"];
    //[self setParameterEncoding:AFJSONParameterEncoding];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetJsonClient)
                                                 name:@"resetAllObjects"
                                               object:nil];
        
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetJsonClient {
    [self stopPortForward];
    __jsonClient = nil;
}

+ (TVHJsonClient*)sharedInstance {
    /*static TVHJsonClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHJsonClient alloc] init];
    });
    
    return __sharedInstance;*/
    if ( ! __jsonClient ) {
        __jsonClient = [[TVHJsonClient alloc] init];
    }
    return __jsonClient;
}

#pragma mark replace


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


#pragma JsonHelper

+ (NSDictionary*)convertFromJsonToObjectFixUtf8:(NSData*)responseData error:(NSError*)error {
    
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
                                                           error:&error];
    
    if( error ) {
        NSLog(@"[JSON Error (2nd)]: %@ ", error.description);
        return nil;
    }
    
    return json;
}

+ (NSDictionary*)convertFromJsonToObject:(NSData*)responseData error:(NSError*)error {
    NSError *errorForThisMethod;
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
        NSLog(@"[JSON Error (1st)]: %@", errorForThisMethod.description);
        return [self convertFromJsonToObjectFixUtf8:responseData error:error];
    }
    
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
        NSError *error = nil;
        sshPortForwardWrapper = [[SSHWrapper alloc] init];
        [sshPortForwardWrapper connectToHost:hostAddress port:sshHostPort user:username password:password error:&error];
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
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [sshPortForwardWrapper closeConnection];
        sshPortForwardWrapper = nil;
    });
}
@end
