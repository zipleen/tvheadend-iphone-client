//
//  TVHConfigNames.h
//  TvhClient
//
//  Created by zipleen on 7/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHConfigName : NSObject
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;

- (void)updateValuesFromDictionary:(NSDictionary*) values;

@end
