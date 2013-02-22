//
//  TVHChannelTests.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/22/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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
    [epg setChannelId:27];
    [epg setTitle:@"Jornal das 8"];
    [epg setDescription:@"Episodio 1.\n"];
    [epg setDuration:6120];
    [epg setStartFromInteger:1361563200];
    [epg setEndFromInteger:1361569320];
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
