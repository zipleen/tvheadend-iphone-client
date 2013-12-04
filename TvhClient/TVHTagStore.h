//
//  TVHTagStore.h
//  TvhClient
//
//  Created by zipleen on 04/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHApiClient.h"

@class TVHServer;

@protocol TVHTagStoreDelegate <NSObject>
@optional
- (void)willLoadTags;
- (void)didLoadTags;
- (void)didErrorLoadingTagStore:(NSError*)error;
@end

@protocol TVHTagStore <TVHApiClientDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHTagStoreDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (NSArray*)tags;
- (void)fetchTagList;
- (void)signalDidLoadTags;
@end
