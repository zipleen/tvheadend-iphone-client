//
//  TVHLogStore.h
//  TvhClient
//
//  Created by Luis Fernandes on 09/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

@protocol TVHLogDelegate <NSObject>
-(void) didLoadLog;
@end

@interface TVHLogStore : NSObject
@property (nonatomic, weak) id <TVHLogDelegate> delegate;
@property (nonatomic, strong) NSString *filter;

- (NSArray*)arrayLogLines;
- (void)clearLog;
@end
