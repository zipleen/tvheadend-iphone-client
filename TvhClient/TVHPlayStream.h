//
//  TVHPlayStream.h
//  TvhClient
//
//  Created by Luis Fernandes on 26/10/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHPlayStreamDelegate.h"

@class TVHServer;

@interface TVHPlayStream : NSObject
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (NSString*)streamUrlForObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding withInternal:(BOOL)internal;

- (NSArray*)arrayOfAvailablePrograms;
- (BOOL)isTranscodingCapable;
- (BOOL)playStreamIn:(NSString*)program forObject:(id<TVHPlayStreamDelegate>)streamObject withTranscoding:(BOOL)transcoding;
@end
