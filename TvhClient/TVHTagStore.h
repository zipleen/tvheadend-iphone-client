//
//  TVHTagStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHApiClient.h"
#import "TVHTag.h"

@class TVHServer;

@protocol TVHTagStoreDelegate <NSObject>
@optional
- (void)willLoadTags;
- (void)didLoadTags;
- (void)didErrorLoadingTagStore:(NSError*)error;
@end

@interface TVHTagStore : NSObject <TVHApiClientDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHTagStoreDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (NSArray*)tags;
- (void)fetchTagList;
- (void)signalDidLoadTags;
@end
