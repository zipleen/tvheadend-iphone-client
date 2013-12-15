//
//  TVHAutoRecStore.h
//  TvhClient
//
//  Created by Luis Fernandes on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAutoRecStore.h"
#import "TVHAutoRecItem.h"
#import "TVHApiClient.h"

@class TVHServer;

@interface TVHAutoRecStoreAbstract : NSObject <TVHApiClientDelegate, TVHAutoRecStore>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHAutoRecStoreDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchDvrAutoRec;

- (TVHAutoRecItem *)objectAtIndex:(int)row;
- (int)count;
@end
