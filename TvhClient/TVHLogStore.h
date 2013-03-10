//
//  TVHLogStore.h
//  TvhClient
//
//  Created by zipleen on 09/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TVHLogDelegate <NSObject>
-(void) didLoadLog;
@end

@interface TVHLogStore : NSObject
+ (id)sharedInstance;
- (void)setDelegate:(id <TVHLogDelegate>)delegate;

- (NSString *) objectAtIndex:(int) row;
- (int) count;
@end
