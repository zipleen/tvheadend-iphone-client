//
//  TVHAdaptersStore.h
//  TvhClient
//
//  Created by zipleen on 05/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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

@protocol TVHAdaptersStore <TVHApiClientDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHAdaptersDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchAdapters;

- (TVHAdapter *)objectAtIndex:(int) row;
- (int)count;
@end

