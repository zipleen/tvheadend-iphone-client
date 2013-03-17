//
//  TVHAdaptersStore.h
//  TvhClient
//
//  Created by zipleen on 06/03/13.
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
#import "TVHAdapter.h"

@protocol TVHAdaptersDelegate <NSObject>
- (void)didLoadAdapters;
- (void)didErrorAdaptersStore:(NSError*)error;
@end

@interface TVHAdaptersStore : NSObject
+ (id)sharedInstance;
- (void)setDelegate:(id <TVHAdaptersDelegate>)delegate;
- (void)fetchAdapters;

- (TVHAdapter *)objectAtIndex:(int) row;
- (int)count;
@end
