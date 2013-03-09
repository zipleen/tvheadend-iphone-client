//
//  TVHPlayStreamHelpController.h
//  TvhClient
//
//  Created by zipleen on 05/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHPlayStreamDelegate.h"

@interface TVHPlayStreamHelpController : NSObject
- (void)playStream:(UIBarButtonItem*)sender withChannel:(id<TVHPlayStreamDelegate>)channel withVC:(UIViewController*)vc;
- (void)playDvr:(UIBarButtonItem*)sender withDvrItem:(id<TVHPlayStreamDelegate>)dvrItem withVC:(UIViewController*)vc;
@end
