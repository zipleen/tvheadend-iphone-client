//
//  TVHJsonHelper.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/17/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHJsonHelper.h"

@implementation TVHJsonHelper

+(NSDictionary*) convertFromJsonToObjectFixUtf8:(NSData*)responseData error:(NSError*)error {
    
    NSMutableData *FileData = [NSMutableData dataWithLength:[responseData length]];
    for (int i = 0; i < [responseData length]; ++i)
    {
        char *a = &((char*)[responseData bytes])[i];
        if( ((int)*a >0 && (int)*a < 0x20)  ) {
            ((char*)[FileData mutableBytes])[i] = 0x20;
        } else {
            ((char*)[FileData mutableBytes])[i] = ((char*)[responseData bytes])[i];
        }
    }
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:FileData //1
                                                         options:kNilOptions
                                                           error:&error];
    
    if( error ) {
        NSLog(@"[JSON Error (2nd)]: %@ ", error.description);
        return nil;
    }
    
    return json;
}

+(NSDictionary*) convertFromJsonToObject:(NSData*)responseData error:(NSError*)error {
    NSError *errorForThisMethod;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData 
                                                         options:kNilOptions
                                                           error:&errorForThisMethod];
    
    if( errorForThisMethod ) {
        /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile"];
         [responseData writeToFile:appFile atomically:YES];
         NSLog(@"%@",documentsDirectory);
         */
        NSLog(@"[JSON Error (1st)]: %@", errorForThisMethod.description);
        return [self convertFromJsonToObjectFixUtf8:responseData error:error];
    }
    
    return json;
}

@end
