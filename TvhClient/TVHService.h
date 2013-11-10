//
//  TVHService.h
//  TvhClient
//
//  Created by zipleen on 09/11/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVHServer.h"
#import "TVHPlayStreamDelegate.h"

@interface TVHService : NSObject <TVHPlayStreamDelegate>
@property (nonatomic, weak) TVHServer *tvhServer;
@property (weak, nonatomic) TVHAdapter *adapterObject;
@property (strong, nonatomic) NSString *id;
@property NSInteger enabled;
@property NSInteger channel;
@property NSInteger sid;
@property NSInteger pmt;
@property NSInteger pcr;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *typestr;
@property NSInteger typenum;
@property (strong, nonatomic) NSString *svcname;
@property (strong, nonatomic) NSString *provider;
@property (strong, nonatomic) NSString *network;
@property (strong, nonatomic) NSString *mux;
@property (strong, nonatomic) NSString *satconf;
@property NSInteger dvb_eit_enable;
@property NSInteger prefcapid;

- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)updateValuesFromDictionary:(NSDictionary*)values;
- (NSComparisonResult)compareByName:(TVHService *)otherObject;
@end
