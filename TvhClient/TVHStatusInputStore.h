//
//  TVHStatusInputStore.h
//  TvhClient
//
//  Created by zipleen on 10/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHApiClient.h"

@class TVHServer;
@class TVHStatusInput;

@protocol TVHStatusInputDelegate <NSObject>
@optional
- (void)willLoadStatusInputs;
- (void)didLoadStatusInputs;
- (void)didErrorStatusInputStore:(NSError*)error;
@end

@protocol TVHStatusInputStore <TVHApiClientDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHStatusInputDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchStatusInputs;

- (TVHStatusInput*)objectAtIndex:(int) row;
- (int)count;
@end

