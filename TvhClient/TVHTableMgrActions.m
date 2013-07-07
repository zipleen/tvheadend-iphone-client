//
//  TVHTableMgrActions.m
//  TvhClient
//
//  Created by zipleen on 3/14/13.
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

#import "TVHTableMgrActions.h"
#import "TVHSingletonServer.h"

@implementation TVHTableMgrActions

+ (void)doTableMgrAction:(NSString*)action inTable:(NSString*)table withEntries:(id)entries {
    TVHJsonClient *httpClient = [[TVHSingletonServer sharedServerInstance] jsonClient];
    NSString *stringEntries;
    
    if ( [entries isKindOfClass:[NSString class]] ) {
        stringEntries = [NSString stringWithFormat:@"\"%@\"",entries];
    } else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:entries
                                                           options:0 
                                                             error:nil];
        stringEntries = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"[%@]", stringEntries],
                            @"entries",
                            action,
                            @"op",
                            table,
                            @"table",nil];
    
    [httpClient postPath:@"/tablemgr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didSuccessTableMgrAction"
             object:action];
                
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
        
        // reload dvr
        TVHAutoRecStore *store = [[TVHSingletonServer sharedServerInstance] autorecStore];
        [store fetchDvrAutoRec];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef TESTING
        NSLog(@"[TableMgr ACTIONS ERROR]: %@", error.localizedDescription);
#endif
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"didErrorTableMgrAction"
         object:error];
    }];
    
}

@end
