//
//  TVHTagStore.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
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
#import "TVHTag.h"

@protocol TVHTagStoreDelegate <NSObject>

- (void)didLoadTags;
- (void)didErrorLoadingTagStore:(NSError*)error;
@end

@interface TVHTagStore : NSObject
+ (id)sharedInstance;
- (void)setDelegate:(id <TVHTagStoreDelegate>)delegate;

- (void)fetchTagList;
- (void)resetTagStore;
- (TVHTag *)objectAtIndex:(int) row;
- (int)count;
@end
