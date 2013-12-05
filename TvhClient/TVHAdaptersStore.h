//
//  TVHAdaptersStore.h
//  TvhClient
//
//  Created by zipleen on 06/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHAdapter.h"
#import "TVHApiClient.h"

@class TVHServer;

@protocol TVHAdaptersDelegate <NSObject>
@optional
- (void)willLoadAdapters;
- (void)didLoadAdapters;
- (void)didErrorAdaptersStore:(NSError*)error;
@end

@interface TVHAdaptersStore : NSObject <TVHApiClientDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHAdaptersDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchAdapters;

- (TVHAdapter *)objectAtIndex:(int) row;
- (int)count;
@end
