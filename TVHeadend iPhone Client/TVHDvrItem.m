//
//  TVHDvrItem.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 28/02/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDvrItem.h"
#import "TVHDvrActions.h"
#import "TVHChannelStore.h"

@implementation TVHDvrItem

-(void)setStart:(id)startDate {
    if( ! [startDate isKindOfClass:[NSString class]] ) {
        _start = [NSDate dateWithTimeIntervalSince1970:[startDate intValue]];
    }
}

-(void)setEnd:(id)endDate {
    if( ! [endDate isKindOfClass:[NSString class]] ) {
        _end = [NSDate dateWithTimeIntervalSince1970:[endDate intValue]];
    }
}

- (void) updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

-(void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

- (void)cancelRecording {
    [TVHDvrActions cancelRecording:self.id];
}

- (void)deleteRecording {
    [TVHDvrActions deleteRecording:self.id];
}

- (TVHChannel*)channelObject {
    TVHChannelStore *store = [TVHChannelStore sharedInstance];
    TVHChannel *channel = [store channelWithName:self.channel];
    return channel;
}

@end
