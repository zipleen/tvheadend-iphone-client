//
//  TVHAutoRecStore.h
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHAutoRecItem.h"

@protocol TVHAutoRecStoreDelegate <NSObject>
-(void) didLoadDvrAutoRec;
@optional
-(void) didErrorDvrAutoStore:(NSError*)error;
@end

@interface TVHAutoRecStore : NSObject
+ (id)sharedInstance;
- (void)setDelegate:(id <TVHAutoRecStoreDelegate>)delegate;
- (void)fetchDvrAutoRec;

- (TVHAutoRecItem *) objectAtIndex:(int)row;
- (int) count;
@end
