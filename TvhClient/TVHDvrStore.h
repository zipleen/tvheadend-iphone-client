//
//  TVHDvrStore.h
//  TvhClient
//
//  Created by Luis Fernandes on 7/9/13.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHDvrItem.h"

#define RECORDING_UPCOMING 0
#define RECORDING_FINISHED 1
#define RECORDING_FAILED 2

@class TVHServer;

@protocol TVHDvrStoreDelegate <NSObject>
@optional
- (void)willLoadDvr:(NSInteger)type;
- (void)didLoadDvr:(NSInteger)type;
- (void)didErrorDvrStore:(NSError*)error;
@end

@protocol TVHDvrStore <NSObject>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHDvrStoreDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchDvr;

- (TVHDvrItem *)objectAtIndex:(int)row forType:(NSInteger)type;
- (int)count:(NSInteger)type;
@end
