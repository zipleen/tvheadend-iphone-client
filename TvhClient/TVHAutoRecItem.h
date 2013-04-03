//
//  TVHAutoRecItem.h
//  TvhClient
//
//  Created by zipleen on 3/14/13.
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

@interface TVHAutoRecItem : NSObject
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *config_name;
@property (nonatomic) NSInteger contenttype;
@property (nonatomic) NSInteger approx_time; // approx_time in minutes
@property (nonatomic, strong) NSString *creator;
@property (nonatomic) NSInteger enabled;
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *pri;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *weekdays; // mon 1, sun 7

- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (void)deleteAutoRec;
@end
