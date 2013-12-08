//
//  TVHStatusSubscriptionsStore.h
//  TvhClient
//
//  Created by Luis Fernandes on 05/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHApiClient.h"
#import "TVHStatusSubscription.h"

@class TVHServer;

@protocol TVHStatusSubscriptionsDelegate <NSObject>
@optional
- (void)willLoadStatusSubscriptions;
- (void)didLoadStatusSubscriptions;
- (void)didErrorStatusSubscriptionsStore:(NSError*)error;
@end

@protocol TVHStatusSubscriptionsStore <TVHApiClientDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHStatusSubscriptionsDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchStatusSubscriptions;

- (TVHStatusSubscription *) objectAtIndex:(int) row;
- (int)count;
@end

