//
//  TVHTableMgrActions.m
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHTableMgrActions.h"
#import "TVHSingletonServer.h"

@implementation TVHTableMgrActions

+ (void)doTableMgrAction:(NSString*)action withJsonClient:(TVHJsonClient*)httpClient inTable:(NSString*)table withEntries:(id)entries {
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
    
    [httpClient postPath:@"tablemgr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
