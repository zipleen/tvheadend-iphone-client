//
//  TVHDvrStore32.h
//  TvhClient
//
//  Created by Luis Fernandes on 7/9/13.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHDvrStore.h"
#import "TVHDvrStoreAbstract.h"

@interface TVHDvrStoreAbstract (Private)
- (void)fetchDvrItemsFromServer: (NSString*)url withType:(NSInteger)type start:(NSInteger)start limit:(NSInteger)limit;
@end

@interface TVHDvrStore32 : TVHDvrStoreAbstract <TVHDvrStore, TVHDvrStoreDelegate>

@end
