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

- (NSURL*) baseURL {
    if( !_baseURL) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *ip = [defaults objectForKey:IP_KEY];
        if(!ip) {
            ip = [[NSString alloc] initWithFormat:@"192.168.1.250"];
        }
        
        NSString *port = [defaults objectForKey:PORT_KEY];
        if(!port) {
            port = [[NSString alloc] initWithFormat:@"9981"];
        }
        
        
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

