//
//  TVHDvrActions.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/28/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDvrActions.h"
#import "TVHJsonClient.h"
#import "TVHDvrStore.h"

@implementation TVHDvrActions

+ (void)doDvrAction:(NSString*)action withEventId:(NSInteger)eventId withConfigName:(NSString*)configName {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%d", eventId ],
                                   @"eventId",
                                   action,
                                   @"op",
                                   configName,
                                   @"configName",nil];
    
    [httpClient postPath:@"/dvr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError* error;
        NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseObject error:error];
        if( error ) {
#if DEBUG
            NSLog(@"[DVR ACTIONS ERROR processing JSON]: %@", error.localizedDescription);
#endif
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didErrorDvrAction"
             object:error];
        }
        NSInteger success = [[json objectForKey:@"success"] intValue];
        if ( success ) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didSuccessDvrAction"
             object:action];
        } else {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didReturnErrorDvrAction"
             object:action];
        }
        
        // reload dvr
        TVHDvrStore *store = [TVHDvrStore sharedInstance];
        [store fetchDvr];
        
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#if DEBUG
        NSLog(@"[DVR ACTIONS ERROR]: %@", error.localizedDescription);
#endif
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"didErrorDvrAction"
         object:error];
    }];

}

+ (void)addRecording:(NSInteger)eventId withConfigName:(NSString*)configName {
    [TVHDvrActions doDvrAction:@"recordEvent" withEventId:eventId withConfigName:configName];
}

+ (void)cancelRecording:(NSInteger)eventId{
    [TVHDvrActions doDvrAction:@"cancelEntry" withEventId:eventId withConfigName:nil];
}

+ (void)deleteRecording:(NSInteger)eventId{
    [TVHDvrActions doDvrAction:@"deleteEntry" withEventId:eventId withConfigName:nil];
}

@end
