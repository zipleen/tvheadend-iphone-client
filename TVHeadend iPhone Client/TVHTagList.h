//
//  TVHTagList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "TVHTag.h"

@protocol TVHTagListDelegate <NSObject>

-(void) didLoadTags;
-(void) didErrorLoading;
@end

@interface TVHTagList : AFHTTPClient
+ (id)sharedInstance;
- (void)setDelegate:(id <TVHTagListDelegate>)delegate;

- (void)fetchTagList;
- (TVHTag *) objectAtIndex:(int) row;
- (int) count;
@end
