//
//  TVHTagStoreTests.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
    STAssertEquals(tag.tagid, 8, @"tag id doesnt match");
    
    tag = [store.tags objectAtIndex:0];
    STAssertEqualObjects(tag.name, @"All Channels", @"tag name does not match");
    STAssertEquals(tag.tagid, 0, @"tag id doesnt match");
    
    tag = [store.tags objectAtIndex:2];
    STAssertEqualObjects(tag.name, @"Desenhos Animados", @"tag name does not match");
    STAssertEquals(tag.tagid, 55, @"tag id doesnt match");
    STAssertEqualObjects(tag.imageUrl, @"http://infantil.png", @"tag id doesnt match");

}

- (void)testJsonTagsParsingDuplicate {
    [self testJsonTagsParsing];
    [self testJsonTagsParsing];
}

@end
