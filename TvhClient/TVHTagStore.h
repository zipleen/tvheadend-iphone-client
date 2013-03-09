//
//  TVHTagList.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHTag.h"

@protocol TVHTagStoreDelegate <NSObject>

-(void) didLoadTags;
-(void) didErrorLoadingTagStore:(NSError*)error;
@end

@interface TVHTagStore : NSObject
+ (id)sharedInstance;
- (void)setDelegate:(id <TVHTagStoreDelegate>)delegate;

- (void)fetchTagList;
- (void) resetTagStore;
- (TVHTag *) objectAtIndex:(int) row;
- (int) count;
@end
