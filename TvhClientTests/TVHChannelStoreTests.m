//
//  TVHChannelStoreTests.m
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/22/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHChannelStoreTests.h"
#import "TVHTestHelper.h"
#import "TVHChannelStore34.h"
#import "TVHChannel.h"
#import "TVHSettings.h"

@interface TVHChannelStore34 (MyPrivateMethodsUsedForTesting)
@property (nonatomic, strong) NSArray *channels;
- (void)fetchedData:(NSData *)responseData;
@end

@implementation TVHChannelStoreTests

- (void)setUp
{
    [super setUp];
    [[TVHSettings sharedInstance] setSortChannel:TVHS_SORT_CHANNEL_BY_NAME];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testJsonChannelParsing
{
    NSData *data = [TVHTestHelper loadFixture:@"Log.channels"];
    TVHChannelStore34 *store = [[TVHChannelStore34 alloc] init];
    STAssertNotNil(store, @"creating channel store object");
    
    [store fetchedData:data];
    STAssertTrue( ([store.channels count] == 7), @"channel count does not match");
    
    TVHChannel *channel = [store.channels lastObject];
    STAssertEqualObjects(channel.name, @"VH", @"tag name does not match");
    STAssertEqualObjects(channel.imageUrl, @"http:///vh.jpg", @"tag name does not match");
    STAssertEquals(channel.number, 143, @"channel number does not match");
    STAssertEquals(channel.chid, 60, @"channel ID does not match");
    NSArray *tags = [[NSArray alloc] initWithObjects:@"8", @"53", nil];
    STAssertEqualObjects(channel.tags, tags, @"channel tags does not match");
    
    channel = [store.channels objectAtIndex:0];
    STAssertEqualObjects(channel.name, @"AXX", @"tag name does not match");
    STAssertEqualObjects(channel.imageUrl, @"http:///ajpg", @"tag name does not match");
    STAssertEquals(channel.number, 60, @"channel number does not match");
    STAssertEquals(channel.chid, 15, @"channel ID does not match");
    
    channel = [store.channels objectAtIndex:2];
    STAssertEqualObjects(channel.name, @"AXX HD", @"tag name does not match");
    STAssertEqualObjects(channel.imageUrl, nil, @"tag name does not match");
    STAssertEquals(channel.number, 0, @"channel number does not match");
    tags = [[NSArray alloc] initWithObjects:@"16", @"19", @"8", nil];
    STAssertEqualObjects(channel.tags, tags, @"channel tags does not match");
    STAssertEquals(channel.chid, 114, @"channel ID does not match");

}

@end
