//
//  TVHAdapters.h
//  TvhClient
//
//  Created by Luis Fernandes on 06/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHMuxStore.h"

@class TVHServer;
@class TVHMux;

@interface TVHAdapter : NSObject <TVHMuxNetwork>

@property NSInteger ber;
@property (strong, nonatomic) NSString *currentMux;
@property (strong, nonatomic) NSString *deliverySystem;
@property (strong, nonatomic) NSString *devicename;
@property NSInteger freqMax;
@property NSInteger freqMin;
@property NSInteger freqStep;
@property (strong, nonatomic) NSString *hostconnection;
@property (strong, nonatomic) NSString *identifier;
@property NSInteger initialMuxes;
@property NSInteger muxes;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *path;
@property NSInteger satConf;
@property NSInteger services;
@property NSInteger signal;
@property float snr;
@property NSInteger symrateMax;
@property NSInteger symrateMin;
@property (strong, nonatomic) NSString *type;
@property NSInteger unc;
@property NSInteger uncavg;
@property NSInteger bw;

- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)updateValuesFromDictionary:(NSDictionary*) values;
- (NSArray*)arrayAdapterMuxes;
- (NSArray*)arrayServicesForMux:(TVHMux*)adapterMux;
- (NSString*)identifierForNetwork;
@end
