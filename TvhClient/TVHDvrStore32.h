//
//  TVHDvrStore32.h
//  TvhClient
//
//  Created by zipleen on 7/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDvrStore.h"
#import "TVHDvrStore34.h"

@interface TVHDvrStore34 (Private)
- (void)fetchDvrItemsFromServer: (NSString*)url withType:(NSInteger)type;
@end

@interface TVHDvrStore32 : TVHDvrStore34

@end
