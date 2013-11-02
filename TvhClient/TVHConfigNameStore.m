//
//  TVHConfigNameStore.m
//  TvhClient
//
//  Created by zipleen on 7/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHConfigNameStore.h"
#import "TVHServer.h"

@interface TVHConfigNameStore ()
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@property (nonatomic, strong) NSArray *configNames;
@end

@implementation TVHConfigNameStore

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
    return self;
}

- (BOOL)fetchedData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        return false;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *configNames = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHConfigName *config = [[TVHConfigName alloc] init];
        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [config setValue:obj forKey:key];
        }];
        [configNames addObject:config];
        
    }];
    
    _configNames = configNames;
#ifdef TESTING
    NSLog(@"[ConfigNames Channels]: %@", _configNames);
#endif
    [TVHDebugLytics setIntValue:[_configNames count] forKey:@"configNames"];
    return true;
}

- (void)fetchConfigNames {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"list", @"op", nil];
    [self.jsonClient postPath:@"confignames" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ( [self fetchedData:responseObject] ) {
            // signal
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[ConfigNames HTTPClient Error]: %@", error.localizedDescription);
    }];
}

@end
