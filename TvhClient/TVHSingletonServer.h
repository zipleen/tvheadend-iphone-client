//
//  TVHSingletonServer.h
//  TvhClient
//
//  Created by zipleen on 16/05/2013.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHServer.h"

@interface TVHSingletonServer : NSObject
+ (TVHSingletonServer*)sharedInstance;
+ (TVHServer*)sharedServerInstance;
@end
