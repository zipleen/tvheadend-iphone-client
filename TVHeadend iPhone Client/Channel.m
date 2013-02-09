//
//  Channel.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "Channel.h"

@interface Channel()
@end

@implementation Channel
@synthesize name = _name;
@synthesize detail = _detail;
@synthesize imageUrl = _imageUrl;
@synthesize number = _number;

@synthesize image = _image;

- (void) setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    self.image = nil;
    //self.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageUrl]];
}
@end
