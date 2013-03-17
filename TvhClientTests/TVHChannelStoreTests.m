//
//  TVHChannelStoreTests.m
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

#import "TVHChannelStoreTests.h"
#import "TVHTestHelper.h"
#import "TVHChannelStore.h"
#import "TVHChannel.h"

@interface TVHChannelStore (MyPrivateMethodsUsedForTesting)
@property (nonatomic, strong) NSArray *channels;
- (void)fetchedData:(NSData *)responseData;
@end

@implementation TVHChannelStoreTests

- (void)tearDown {
    TVHChannelStore *store = [TVHChannelStore sharedInstance];
    store.channels = nil;
    [super tearDown];
}

- (void)testJsonTagsParsing
{
    NSData *data = [TVHTestHelper loadFixture:@"Log.channels"];
    TVHChannelStore *store = [TVHChannelStore sharedInstance];
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
