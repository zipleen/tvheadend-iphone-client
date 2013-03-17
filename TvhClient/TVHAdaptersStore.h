//
//  TVHAdaptersStore.h
//  TvhClient
//
//  Created by zipleen on 06/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHAdapter.h"

@protocol TVHAdaptersDelegate <NSObject>
- (void)didLoadAdapters;
- (void)didErrorAdaptersStore:(NSError*)error;
@end

@interface TVHAdaptersStore : NSObject
+ (id)sharedInstance;
- (void)setDelegate:(id <TVHAdaptersDelegate>)delegate;
- (void)fetchAdapters;

- (TVHAdapter *)objectAtIndex:(int) row;
- (int)count;
@end
