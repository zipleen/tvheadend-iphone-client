//
//  TVHPlayStreamHelpController.h
//  TvhClient
//
//  Created by zipleen on 05/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHPlayStreamDelegate.h"

@interface TVHPlayStreamHelpController : NSObject
- (void)playStream:(id)sender withChannel:(id<TVHPlayStreamDelegate>)channel withVC:(UIViewController*)vc;
- (void)playDvr:(UIBarButtonItem*)sender withDvrItem:(id<TVHPlayStreamDelegate>)dvrItem withVC:(UIViewController*)vc;
- (void)dismissActionSheet;
@end
