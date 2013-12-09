//
//  TVHServiceStore34.m
//  TvhClient
//
//  Created by Luis Fernandes on 08/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHServiceStore34.h"

@implementation TVHServiceStore34

#pragma mark Api Client delegates

- (NSString*)apiMethod {
    if ( self.identifier ) {
        return @"POST";
    }
    return nil;
}

- (NSString*)apiPath {
    if ( self.identifier ) {
        return [@"dvb/services/" stringByAppendingString:self.identifier];
    }
    return nil;
}

- (NSDictionary*)apiParameters {
    return [NSDictionary dictionaryWithObjectsAndKeys:@"get", @"op", nil];
}


@end
