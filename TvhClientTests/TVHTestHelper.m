//
//  TVHTestHelper.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHTestHelper.h"

@implementation TVHTestHelper

+ (NSData *)loadFixture:(NSString *)name
{
    NSBundle *unitTestBundle = [NSBundle bundleForClass:[self class]];
    NSString *pathForFile    = [unitTestBundle pathForResource:name ofType:nil];
    NSData   *data           = [[NSData alloc] initWithContentsOfFile:pathForFile];
    return data;
}

@end
