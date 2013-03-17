//
//  TVHAdapters.h
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

- (void)updateValuesFromDictionary:(NSDictionary*) values;
@end
