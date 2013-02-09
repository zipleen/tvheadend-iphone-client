//
//  Channel.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHChannel : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSData *image;
@end
