//
//  TVHStatusSubscriptionsStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHStatusSubscription.h"

@class TVHServer;

@protocol TVHStatusSubscriptionsDelegate <NSObject>
@optional
- (void)willLoadStatusSubscriptions;
- (void)didLoadStatusSubscriptions;
- (void)didErrorStatusSubscriptionsStore:(NSError*)error;
@end

@interface TVHStatusSubscriptionsStore : NSObject
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHStatusSubscriptionsDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchStatusSubscriptions;

- (TVHStatusSubscription *) objectAtIndex:(int) row;
- (int)count;
@end
