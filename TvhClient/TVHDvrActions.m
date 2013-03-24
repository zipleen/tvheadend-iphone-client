//
//  TVHDvrActions.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/28/13.
//  Copyright 2013 Luis Fernandes
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TVHDvrActions.h"
#import "TVHJsonClient.h"
#import "TVHDvrStore.h"

@implementation TVHDvrActions

+ (void)doDvrAction:(NSString*)action withId:(NSInteger)idint withIdName:(NSString*)idName withConfigName:(NSString*)configName {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%d", idint ],
                                   idName,
                                   action,
                                   @"op",
                                   configName,
                                   @"configName",nil];
    
    [httpClient postPath:@"/dvr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError* error;
        NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseObject error:error];
        if( error ) {
#ifdef TESTING
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
#ifdef TESTING
        NSLog(@"[DVR ACTIONS ERROR]: %@", error.localizedDescription);
#endif
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"didErrorDvrAction"
         object:error];
    }];

}

+ (void)addRecording:(NSInteger)eventId withConfigName:(NSString*)configName {
    [TVHDvrActions doDvrAction:@"recordEvent" withId:eventId withIdName:@"eventId" withConfigName:configName];
}

+ (void)cancelRecording:(NSInteger)entryId{
    [TVHDvrActions doDvrAction:@"cancelEntry" withId:entryId withIdName:@"entryId" withConfigName:nil];
}

+ (void)deleteRecording:(NSInteger)entryId{
    [TVHDvrActions doDvrAction:@"deleteEntry" withId:entryId withIdName:@"entryId" withConfigName:nil];
}

+ (void)addAutoRecording:(NSInteger)eventId withConfigName:(NSString*)configName {
    [TVHDvrActions doDvrAction:@"recordSeries" withId:eventId withIdName:@"eventId" withConfigName:configName];
}

@end
