//
//  TVHStatusSubscription.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/18/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHStatusSubscription : NSObject
@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) NSString *errors;
@property (strong, nonatomic) NSString *hostname;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *service;
@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *title;
@end
