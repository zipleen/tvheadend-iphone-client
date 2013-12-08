//
//  TVHDvrStore.h
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 28/02/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHDvrStore.h"
#import "TVHApiClient.h"

@interface TVHDvrStoreAbstract : NSObject <TVHDvrStore, TVHApiClientDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHDvrStoreDelegate> delegate;
@property (nonatomic, strong) NSArray *dvrItems;
@property (nonatomic, strong) NSArray *cachedDvrItems; // the table delegate will get only the items in this array
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchDvr;

- (TVHDvrItem *)objectAtIndex:(int)row forType:(NSInteger)type;
- (int)count:(NSInteger)type;
- (void)signalDidLoadDvr:(NSInteger)type;
@end
