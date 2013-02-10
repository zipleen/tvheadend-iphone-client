//
//  TVHTag.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHTag.h"

@implementation TVHTag
@synthesize tagid = _tagid;
@synthesize name = _name;
@synthesize comment = _comment;
@synthesize imageUrl = _imageUrl;

-(id) initWithAllChannels {
    self = [super init];
    if (self) {
        self.tagid = 0;
        self.name = @"All Channels";

    }
    return self;
}

@end
