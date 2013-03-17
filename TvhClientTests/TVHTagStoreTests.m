//
//  TVHTagStoreTests.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
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

#import "TVHTagStoreTests.h"
#import "TVHTestHelper.h"
#import "TVHTagStore.h"
#import "TVHTag.h"

@interface TVHTagStore (MyPrivateMethodsUsedForTesting) 

@property (nonatomic, strong) NSArray *tags;
- (void)fetchedData:(NSData *)responseData;
@end

@implementation TVHTagStoreTests

- (void)tearDown {
    TVHTagStore *store = [TVHTagStore sharedInstance];
    store.tags = nil;
    [super tearDown];
}

- (void)testJsonTagsParsing {
    NSData *data = [TVHTestHelper loadFixture:@"Log.tags"];
    TVHTagStore *store = [TVHTagStore sharedInstance];
    STAssertNotNil(store, @"creating tvhtag store object");
    NSLog(@"olha aqui: %d", [store.tags count]);
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
