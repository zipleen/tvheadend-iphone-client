//
//  TVHSingletonServer.h
//  TvhClient
//
//  Created by zipleen on 16/05/2013.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHServer.h"

@interface TVHSingletonServer : NSObject
+ (TVHServer*)sharedServerInstance;
@end
