//
//  TVHAdapters.h
//  TvhClient
//
//  Created by zipleen on 06/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHAdapter : NSObject

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

- (void) updateValuesFromDictionary:(NSDictionary*) values;
@end
