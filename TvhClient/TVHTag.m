//
//  TVHTag.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHTag.h"
#import "TVHServer.h"

@interface TVHTag()
@property (nonatomic, weak) TVHServer *tvhServer;
@end

@implementation TVHTag

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    return self;
}

- (void)dealloc {
    self.name = nil;
    self.comment = nil;
    self.icon = nil;
}

- (id)initWithAllChannels:(TVHServer*)tvhServer {
    self = [super init];
    if (self) {
        self.id = 0;
        self.name = NSLocalizedString(@"All Channels", nil);
        self.tvhServer = tvhServer;
    }
    return self;
}

- (void)updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (NSComparisonResult)compareByName:(TVHTag *)otherObject {
    return [self.name compare:otherObject.name];
}

- (BOOL)isEqual: (id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    TVHTag *otherCast = other;
    if ( self.idKey == otherCast.idKey ) {
        return YES;
    }
    return NO;
}

- (NSString*)idKey {
    return [NSString stringWithFormat:@"%d", self.id];
}

- (NSInteger)channelCount {
    NSInteger count = 0;
    NSArray *channels = [[self.tvhServer channelStore] channels];
    if ( [self.idKey isEqualToString:@"0"] ) {
        return [channels count];
    }
    
    for (TVHChannel *channel in channels) {
        if ( [channel hasTag:self.idKey] ) {
            count++;
        }
    }
    return count;
}

@end
