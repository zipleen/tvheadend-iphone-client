//
//  TVHConfigNameStore.h
//  TvhClient
//
//  Created by zipleen on 7/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHConfigName.h"

@class TVHServer;

@interface TVHConfigNameStore : NSObject
@property (nonatomic, weak) TVHServer *tvhServer;

- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchConfigNames;
@end
