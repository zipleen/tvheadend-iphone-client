//
//  TVHEpgStoreTests.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/16/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpgStoreTests.h"
#import "TVHTestHelper.h"
#import "TVHEpgStore.h"

@interface TVHEpgStore (MyPrivateMethodsUsedForTesting)
@property (nonatomic, strong) NSArray *epgStore;
- (void)fetchedData:(NSData *)responseData;
@end


@implementation TVHEpgStoreTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testJsonCharacterBug
{
    NSData *data = [TVHTestHelper loadFixture:@"Log.287"];
    TVHEpgStore *tvhe = [TVHEpgStore sharedInstance];
    STAssertNotNil(tvhe, @"creating tvepg store object");
    [tvhe fetchedData:data];
    STAssertTrue( ([tvhe.epgStore count] == 1), @"Failed parsing json data");
    
    TVHEpg *epg = [tvhe.epgStore objectAtIndex:0];
    STAssertEqualObjects(epg.title, @"Nacional x Benfica - Primeira Liga", @"epg title doesnt match");
    STAssertEquals(epg.channelId, 131, @"epg title doesnt match");
}



@end
