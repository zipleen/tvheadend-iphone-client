//
//  TVHJsonHelper.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHJsonHelper : NSObject
+(NSDictionary*) convertFromJsonToObject:(NSData*)responseData error:(NSError*)error;
@end
