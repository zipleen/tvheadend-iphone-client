//
//  TVHDvrStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 28/02/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHDvrItem.h"

@protocol TVHDvrStoreDelegate <NSObject>
-(void) didLoadDvr;
-(void) didErrorDvrStore:(NSError*)error;
@end

@interface TVHDvrStore : NSObject
+ (id)sharedInstance;
- (void)setDelegate:(id <TVHDvrStoreDelegate>)delegate;
- (void)fetchDvr;

- (TVHDvrItem *) objectAtIndex:(int) row;
- (int) count;
@end
