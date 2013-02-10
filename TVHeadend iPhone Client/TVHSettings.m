//
//  TVHSettings.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHSettings.h"

@interface TVHSettings()

@end

@implementation TVHSettings
#define IP_KEY @"IP"
#define PORT_KEY @"PORT"
@synthesize baseURL = _baseURL;
@synthesize ip = _ip;

- (NSString*) ip {
    if(!_ip) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _ip = [defaults objectForKey:IP_KEY];
    }
    return _ip;
}

- (NSURL*) baseURL {
    if( !_baseURL) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *ip = [defaults objectForKey:IP_KEY];
        NSString *port = [defaults objectForKey:PORT_KEY];
        
        NSString *baseUrlString = [NSString stringWithFormat:@"http://%@:%@", ip, port];
        NSURL *url = [NSURL URLWithString:baseUrlString];
        _baseURL = url;
    }
    return _baseURL;
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

