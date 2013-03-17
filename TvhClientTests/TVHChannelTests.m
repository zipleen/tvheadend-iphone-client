//
//  TVHChannelTests.m
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

#import "TVHChannelTests.h"
#import "TVHTestHelper.h"
#import "TVHChannel.h"
#import "TVHEpg.h"
#import "TVHEpgStore.h"
#import "TVHChannelEpg.h"

@interface TVHChannel (MyPrivateMethodsUsedForTesting) 
@property (nonatomic, strong) NSMutableArray *channelEpgDataByDay;
@end

@interface TVHEpgStore (MyPrivateMethodsUsedForTesting)
- (void)fetchedData:(NSData *)responseData;
@end

@implementation TVHChannelTests 

- (TVHChannel*)channel {
    TVHChannel *channel = [[TVHChannel alloc] init];
    
    return channel;
}

- (TVHEpg*)epg {
    TVHEpg *epg = [[TVHEpg alloc] init];
    [epg updateValuesFromDictionary:@{
        @"channelid":@27,
        @"title":@"Jornal das 8",
        @"description":@"Episodio 1.\n",
        @"duration":@6120,
        @"start":@1361563200,
        @"end":@1361569320 }];
    return epg;
}

- (void)didLoadEpgChannel{}

- (void)testDuplicateEpg {
    
    TVHChannel *channel = [self channel];
    TVHEpg *epg = [self epg];
    
    [channel addEpg:epg];
    TVHChannelEpg *chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 1), @"epg not inserted");
    
    [channel addEpg:epg];
    chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 1), @"programs == %d should be 1", [chepg.programs count]);

    [channel addEpg:epg];
    chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 1), @"programs == %d should be 1", [chepg.programs count]);
}

- (void)testDuplicateEpgFromFetchMorePrograms {
    NSData *data = [TVHTestHelper loadFixture:@"Log.oneChannelEpg"];
    TVHEpgStore *store = [[TVHEpgStore alloc ] init];
    [store fetchedData:data];
    
    TVHChannel *channel = [self channel];
    TVHEpg *epg = [self epg];
    
    [channel setDelegate:self];
    [channel addEpg:epg];
    TVHChannelEpg *chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 1), @"epg not inserted");
    
    [channel didLoadEpg:store];
    chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 4), @"programs == %d should be 20", [chepg.programs count]);

    [channel didLoadEpg:store];
    chepg = [channel.channelEpgDataByDay objectAtIndex:0];
    STAssertTrue( ([chepg.programs count] == 4), @"programs == %d should be 20", [chepg.programs count]);
}

@end
