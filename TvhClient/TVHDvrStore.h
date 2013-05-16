//
//  TVHDvrStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 28/02/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "TVHDvrItem.h"

#define RECORDING_UPCOMING 0
#define RECORDING_FINISHED 1
#define RECORDING_FAILED 2

@class TVHServer;

@protocol TVHDvrStoreDelegate <NSObject>
-(void) didLoadDvr:(NSInteger)type;
-(void) didErrorDvrStore:(NSError*)error;
@end

@interface TVHDvrStore : NSObject
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)setDelegate:(id <TVHDvrStoreDelegate>)delegate;
- (void)fetchDvr;

- (TVHDvrItem *)objectAtIndex:(int)row forType:(NSInteger)type;
- (int)count:(NSInteger)type;
@end
