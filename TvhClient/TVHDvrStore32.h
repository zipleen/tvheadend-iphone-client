//
//  TVHDvrStore32.h
//  TvhClient
//
//  Created by zipleen on 7/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHDvrStore.h"
#import "TVHDvrStore34.h"

@interface TVHDvrStore34 (Private)
- (void)fetchDvrItemsFromServer: (NSString*)url withType:(NSInteger)type;
@end

@interface TVHDvrStore32 : TVHDvrStore34

@end
