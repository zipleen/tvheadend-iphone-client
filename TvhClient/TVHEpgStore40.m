//
//  TVHEpgStore40.m
//  TvhClient
//
//  Created by Luis Fernandes on 02/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
