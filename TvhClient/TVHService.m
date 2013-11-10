//
//  TVHService.m
//  TvhClient
//
//  Created by zipleen on 09/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHService.h"

@interface TVHService()
@property (nonatomic, weak) TVHJsonClient *jsonClient;
@end

@implementation TVHService

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.jsonClient = [self.tvhServer jsonClient];
    
    return self;
}

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (NSComparisonResult)compareByName:(TVHService *)otherObject {
    return [self.svcname compare:otherObject.svcname];
}

- (NSString*)streamURL {
    return [NSString stringWithFormat:@"%@/stream/service/%@", [self.tvhServer baseUrl], self.id];
}

- (NSString*)playlistStreamURL {
    return [NSString stringWithFormat:@"%@/playlist/stream/%@", [self.tvhServer baseUrl], self.id];
}

- (NSString*)htspStreamURL {
    return nil;
    return [NSString stringWithFormat:@"%@/service/%@.ts", [self.tvhServer htspUrl], self.id];
}

@end
