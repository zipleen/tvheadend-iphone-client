//
//  TVHStringHelper.m
//  TvhClient
//
//  Created by zipleen on 06/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "NSString+FileSize.h"

@implementation NSString (NSStringWithFileSize)

+ (NSString *)stringFromFileSize:(unsigned long long)theSize {
    float floatSize = (float)theSize;
    
    if ( theSize == 0 ) {
        return @"0";
    }
    
    if ( theSize < 1023 ){
        return ([NSString stringWithFormat:@"%llul bytes",theSize]);
    }
    
    floatSize = floatSize / 1024;
    if ( floatSize < 1023 ){
        return ([NSString stringWithFormat:@"%1.1f KB",floatSize]);
    }
    
    floatSize = floatSize / 1024;
    if ( floatSize < 1023 ) {
        return ([NSString stringWithFormat:@"%1.1f MB",floatSize]);
    }
    
    floatSize = floatSize / 1024;
    if ( floatSize < 1023 ) {
        return ([NSString stringWithFormat:@"%1.1f GB",floatSize]);
    }
    
    floatSize = floatSize / 1024;
    return([NSString stringWithFormat:@"%1.1f TB",floatSize]);
}

+ (NSString *)stringFromFileSizeInBits:(unsigned long long)theSize {
    return [NSString stringFromFileSize: theSize*8];
}

@end
