//
//  TVHStatusSubscriptionsStore.h
//  TvhClient
//
//  Created by zipleen on 05/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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

