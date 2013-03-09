//
//  TVHTag.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHTag : NSObject
@property (nonatomic) NSInteger tagid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *imageUrl;

-(id) initWithAllChannels;
@end
