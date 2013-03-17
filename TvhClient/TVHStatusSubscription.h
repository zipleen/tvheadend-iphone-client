//
//  TVHStatusSubscription.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
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

@interface TVHStatusSubscription : NSObject
@property (strong, nonatomic) NSString *channel;
@property NSInteger errors;
@property (strong, nonatomic) NSString *hostname;
@property NSInteger id;
@property (strong, nonatomic) NSString *service;
@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *title;
@property NSInteger bw;

- (void)updateValuesFromDictionary:(NSDictionary*) values;
@end
