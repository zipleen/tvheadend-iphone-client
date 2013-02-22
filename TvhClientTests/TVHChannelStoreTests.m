//
//  TVHChannelStoreTests.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
    NSArray *tags = [[NSArray alloc] initWithObjects:@"8", @"53", nil];
    STAssertEqualObjects(channel.tags, tags, @"channel tags does not match");
    
    channel = [store.channels objectAtIndex:0];
    STAssertEqualObjects(channel.name, @"AXX", @"tag name does not match");
    STAssertEqualObjects(channel.imageUrl, @"http:///ajpg", @"tag name does not match");
    STAssertEquals(channel.number, 60, @"channel number does not match");
    
    channel = [store.channels objectAtIndex:2];
    STAssertEqualObjects(channel.name, @"AXX HD", @"tag name does not match");
    STAssertEqualObjects(channel.imageUrl, nil, @"tag name does not match");
    STAssertEquals(channel.number, 0, @"channel number does not match");
    tags = [[NSArray alloc] initWithObjects:@"16", @"19", @"8", nil];
    STAssertEqualObjects(channel.tags, tags, @"channel tags does not match");

}

@end
