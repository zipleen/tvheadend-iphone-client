//
//  TVHPlayXbmc.h
//  TvhClient
//
//  Created by zipleen on 27/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHPlayXbmc : NSObject
+ (TVHPlayXbmc*)sharedInstance;
- (NSArray*)availableXbmcServers;
- (BOOL)playToXbmc:(NSString*)name withURL:(NSString*)url;
@end
