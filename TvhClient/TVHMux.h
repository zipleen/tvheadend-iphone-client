//
//  TVHAdapterMux.h
//  TvhClient
//
//  Created by Luis Fernandes on 30/07/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHAdapter.h"

@class TVHServer;

@interface TVHMux : NSObject
@property (strong, nonatomic) NSString *adapterId;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *freq;
@property (strong, nonatomic) NSString *mod;
@property (strong, nonatomic) NSString *fe_status;
@property (strong, nonatomic) NSString *pol;
@property (strong, nonatomic) NSString *satconf;
@property NSInteger muxid;
@property NSInteger quality;

// shared
@property (strong, nonatomic) NSString *network;
@property NSInteger enabled;
@property NSInteger onid;

// 4.0
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *delsys; // delivery system
@property NSInteger frequency;
@property (strong, nonatomic) NSString *bandwidth;
@property (strong, nonatomic) NSString *constellation;
@property (strong, nonatomic) NSString *transmission_mode;
@property (strong, nonatomic) NSString *guard_interval;
@property (strong, nonatomic) NSString *hierarchy;
@property (strong, nonatomic) NSString *fec_hi;
@property (strong, nonatomic) NSString *fec_lo;
@property NSInteger tsid;
@property NSInteger initscan;
@property NSInteger num_svc;

- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)updateValuesFromDictionary:(NSDictionary*)values;
- (void)updateValuesFromTVHMux:(TVHMux*)mux;
- (NSComparisonResult)compareByFreq:(TVHMux *)otherObject;

@end
