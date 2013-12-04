//
//  TVHEpgStore40.m
//  TvhClient
//
//  Created by zipleen on 02/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpgStore40.h"
#import "TVHServer.h"

@interface TVHEpgStore40 (MyPrivateMethods)
@property (nonatomic, strong) NSArray *epgStore;
@end

@implementation TVHEpgStore40
@synthesize filterToChannelName = _filterToChannelName;

- (NSString*)jsonApiFieldEntries {
    return @"events";
}

- (NSString*)apiPath {
    return @"api/epg/grid";
}

- (NSString*)apiMethod {
    return @"GET";
}

- (void)setFilterToChannelName:(NSString *)filterToChannelName {
    id <TVHChannelStore> store = [self.tvhServer channelStore];
    TVHChannel *channel = [store channelWithName:filterToChannelName];
    
    if ( channel ) {
        filterToChannelName = channel.channelIdKey;
        if ( ! [filterToChannelName isEqualToString:_filterToChannelName] ) {
            _filterToChannelName = filterToChannelName;
            self.epgStore = nil;
        }
    }
}

@end
