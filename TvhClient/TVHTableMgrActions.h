//
//  TVHAutoRecActions.h
//  TvhClient
//
//  Created by Luis Fernandes on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHJsonClient.h"

@interface TVHTableMgrActions : NSObject
+ (void)doTableMgrAction:(NSString*)action withJsonClient:(TVHJsonClient*)httpClient inTable:(NSString*)table withEntries:(id)entries;
@end
