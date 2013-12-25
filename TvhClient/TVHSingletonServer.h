//
//  TVHSingletonServer.h
//  TvhClient
//
//  Created by Luis Fernandes on 16/05/2013.
//  Copyright (c) 2013 Luis Fernandes. 
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHServer.h"

#define TVHWillDestroyServerNotification @"resetAllObjects"

@interface TVHSingletonServer : NSObject
+ (TVHSingletonServer*)sharedInstance;
+ (TVHServer*)sharedServerInstance;
@end
