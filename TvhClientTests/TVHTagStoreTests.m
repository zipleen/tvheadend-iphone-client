//
//  TVHTagStoreTests.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/22/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHTagStoreTests.h"
#import "TVHTestHelper.h"
#import "TVHTagStore34.h"
#import "TVHTag.h"

@interface TVHTagStore34 (MyPrivateMethodsUsedForTesting)

@property (nonatomic, strong) NSArray *tags;
- (void)fetchedData:(NSData *)responseData;
@end

@implementation TVHTagStoreTests

- (void)tearDown {
    [super tearDown];
}

- (void)testJsonTagsParsing {
    NSData *data = [TVHTestHelper loadFixture:@"Log.tags"];
    TVHTagStore34 *store = [[TVHTagStore34 alloc] init];
    STAssertNotNil(store, @"creating tvhtag store object");
    [store fetchedData:data];
    STAssertTrue( ([store.tags count] == 13+1), @"tag count does not match");
    
    TVHTag *tag = [store.tags lastObject];
    STAssertEqualObjects(tag.name, @"Z", @"tag name does not match");
    STAssertEquals(tag.id, 8, @"tag id doesnt match");
    
    tag = [store.tags objectAtIndex:0];
    STAssertEqualObjects(tag.name, @"All Channels", @"tag name does not match");
    STAssertEquals(tag.id, 0, @"tag id doesnt match");
    
    tag = [store.tags objectAtIndex:2];
    STAssertEqualObjects(tag.name, @"Desenhos Animados", @"tag name does not match");
    STAssertEquals(tag.id, 55, @"tag id doesnt match");
    STAssertEqualObjects(tag.icon, @"http://infantil.png", @"tag id doesnt match");

}

- (void)testJsonTagsParsingDuplicate {
    [self testJsonTagsParsing];
    [self testJsonTagsParsing];
}

@end
