//
//  TVHEpgStoreTests.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/16/13.
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
    TVHEpgStore *tvhe = [TVHEpgStore sharedInstance];
    tvhe.epgStore = nil;
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
    STAssertEquals(epg.channelid, 131, @"epg channel id doesnt match");
    STAssertEqualObjects(epg.channel, @"Sport TV 1 Meo", @"channel name does not match" );
    STAssertEqualObjects(epg.chicon, @"https://dl.dropbox.com/u/a/TVLogos/sport_tv1_pt.jpg", @"channel name does not match" );
    STAssertFalse([epg.description isEqualToString:@""], @"description empty");
    STAssertEquals(epg.id, 400297, @"epg id does not match" );
    STAssertEquals(epg.duration, 8100, @"epg id does not match" );
    STAssertEqualObjects(epg.start, [NSDate dateWithTimeIntervalSince1970:1360519200], @"start date does not match" );
    STAssertEqualObjects(epg.end, [NSDate dateWithTimeIntervalSince1970:1360527300], @"end date does not match" );
}



@end
