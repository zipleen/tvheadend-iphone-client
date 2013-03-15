//
//  TVHAutoRecActions.h
//  TvhClient
//
//  Created by zipleen on 3/14/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVHTableMgrActions : NSObject
+(void)doTableMgrAction:(NSString*)action inTable:(NSString*)table withEntries:(id)entries;
@end
