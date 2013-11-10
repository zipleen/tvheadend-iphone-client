//
//  TVHAdapterMux.h
//  TvhClient
//
//  Created by zipleen on 30/07/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHAdapter.h"
#import "TVHServer.h"

@interface TVHAdapterMux : NSObject
@property (weak, nonatomic) TVHAdapter *adapterObject;
@property (strong, nonatomic) NSString *adapterId;
@property (strong, nonatomic) NSString *id;
@property NSInteger enabled;
@property (strong, nonatomic) NSString *network;
@property (strong, nonatomic) NSString *freq;
@property (strong, nonatomic) NSString *mod;
@property (strong, nonatomic) NSString *fe_status;
@property (strong, nonatomic) NSString *pol;
@property (strong, nonatomic) NSString *satconf;
@property NSInteger muxid;
@property NSInteger onid;
@property NSInteger quality;

- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)updateValuesFromDictionary:(NSDictionary*)values;
- (NSComparisonResult)compareByFreq:(TVHAdapterMux *)otherObject;

@end
