//
//  TVHAdaptersStore34.m
//  TvhClient
//
//  Created by Luis Fernandes on 05/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAdaptersStore34.h"
#import "TVHServer.h"

@implementation TVHAdaptersStore34

- (void)setupMoreValuesForAdapter:(TVHAdapter*)adapter {
    [self fetchMuxesFor:adapter];
    [self fetchServicesFor:adapter];
}

- (void)fetchMuxesFor:(TVHAdapter*)adapter {
    id <TVHMuxStore> muxStore = [self.tvhServer muxStore];
    [muxStore setIdentifier:adapter.identifier];
    [muxStore fetchMuxes];
}

- (void)fetchServicesFor:(TVHAdapter*)adapter {
    id <TVHServiceStore> serviceStore = [self.tvhServer serviceStore];
    [serviceStore setIdentifier:adapter.identifier];
    [serviceStore fetchServices];
}

@end
