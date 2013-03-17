//
//  TVHStatusSubscription.m
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

#import "TVHStatusSubscription.h"

@implementation TVHStatusSubscription

- (void)dealloc {
    self.channel = nil;
    self.hostname = nil;
    self.service = nil;
    self.start = nil;
    self.state = nil;
    self.title = nil;
}

- (void)setStart:(id)startDate {
    if([startDate isKindOfClass:[NSNumber class]]) {
        _start = [NSDate dateWithTimeIntervalSince1970:[startDate intValue]];
    }
}

- (void) updateValuesFromDictionary:(NSDictionary*) values {
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
    
}

@end
