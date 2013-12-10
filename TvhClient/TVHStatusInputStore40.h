//
//  TVHStatusInputStore40.h
//  TvhClient
//
//  Created by zipleen on 10/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHStatusInputStore.h"
#import "TVHStatusInput.h"

@class TVHServer;

@interface TVHStatusInputStore40 : NSObject <TVHApiClientDelegate, TVHStatusInputStore>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (nonatomic, weak) id <TVHStatusInputDelegate> delegate;
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchStatusInputs;

- (TVHStatusInput*)objectAtIndex:(int) row;
- (int)count;
@end
