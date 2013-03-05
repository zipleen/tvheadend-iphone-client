//
//  TVHPlayStreamHelpController.h
//  TvhClient
//
//  Created by zipleen on 05/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHChannel.h"

@interface TVHPlayStreamHelpController : NSObject
- (void)playStream:(UIBarButtonItem*)sender withChannel:(TVHChannel*)channel withVC:(UIViewController*)vc;
@end
