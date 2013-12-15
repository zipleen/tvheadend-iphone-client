//
//  TVHPlayXbmc.h
//  TvhClient
//
//  Created by Luis Fernandes on 27/10/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHPlayStreamDelegate.h"

@interface TVHPlayXbmc : NSObject
+ (TVHPlayXbmc*)sharedInstance;
- (NSArray*)availableXbmcServers;
- (NSDictionary*)foundServices;
- (NSString*)validUrlForObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding;
@end
