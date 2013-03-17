//
//  TVHTableMgrActions.m
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHTableMgrActions.h"
#import "TVHJsonClient.h"

@implementation TVHTableMgrActions

+ (void)doTableMgrAction:(NSString*)action inTable:(NSString*)table withEntries:(id)entries {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            entries,
                            @"entries",
                            action,
                            @"op",
                            table,
                            @"table",nil];
    
    [httpClient postPath:@"/tablemgr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError* error;
        if( error ) {
#ifdef TESTING
            NSLog(@"[TableMgr ACTIONS ERROR processing JSON]: %@", error.localizedDescription);
#endif
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didErrorTableMgrAction"
             object:error];
        }
        
        [[NSNotificationCenter defaultCenter]
             postNotificationName:@"didSuccessTableMgrAction"
             object:action];
                
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
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
