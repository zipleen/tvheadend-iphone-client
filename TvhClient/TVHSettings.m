//
//  TVHSettings.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
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

#import "TVHSettings.h"

@interface TVHSettings()

@end

@implementation TVHSettings
#define IP_KEY @"IP"
#define PORT_KEY @"PORT"
#define USERNAME_KEY @"USERNAME"
#define PASSWORD_KEY @"PASSWORD"
@synthesize baseURL = _baseURL;
@synthesize ip = _ip;

- (NSString*)ip {
    if(!_ip) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _ip = [defaults objectForKey:IP_KEY];
    }
    return _ip;
}

- (NSURL*)baseURL {
    if( !_baseURL) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *ip = [defaults objectForKey:IP_KEY];
        NSString *port = [defaults objectForKey:PORT_KEY];
        if(!port) {
            port = @"9981";
        }
        
        NSString *baseUrlString = [NSString stringWithFormat:@"http://%@:%@", ip, port];
        NSURL *url = [NSURL URLWithString:baseUrlString];
        _baseURL = url;
    }
    return _baseURL;
}

- (NSString*)username {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:USERNAME_KEY];
}

// FIX: Password in cleartext!!! NEEDS TO USE KEYCHAIN!!!!!
- (NSString*)password {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:PASSWORD_KEY];
}

- (void)resetSettings {
    _ip = nil;
    _baseURL = nil;
}

- (NSTimeInterval)cacheTime {
    return 300;
}

+ (id)sharedInstance {
    static TVHSettings *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHSettings alloc] init];
    });
    
    return __sharedInstance;
}


@end

