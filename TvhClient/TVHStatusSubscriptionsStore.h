//
//  TVHStatusSubscriptionsStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHStatusSubscription.h"

@protocol TVHStatusSubscriptionsDelegate <NSObject>
- (void)didLoadStatusSubscriptions;
- (void)didErrorStatusSubscriptionsStore:(NSError*)error;
@end

@interface TVHStatusSubscriptionsStore : NSObject

+ (id)sharedInstance;
- (void)setDelegate:(id <TVHStatusSubscriptionsDelegate>)delegate;
- (void)fetchStatusSubscriptions;

- (TVHStatusSubscription *) objectAtIndex:(int) row;
- (int)count;
@end
