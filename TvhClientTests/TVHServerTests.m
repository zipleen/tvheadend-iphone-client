//
//  TVHServerTests.m
//  TvhClient
//
//  Created by zipleen on 7/21/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHServerTests.h"
#import "TVHTestHelper.h"
#import "TVHServer.h"

@interface TVHServer (MyPrivateMethodsUsedForTesting)
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *realVersion;
//@property (nonatomic, strong) NSArray *capabilities;
- (void)handleFetchedServerVersion:(NSString*)response;
@end


@implementation TVHServerTests

- (void)testServerVersions {
    TVHServer *server = [[TVHServer alloc] init];
    NSData *data = [TVHTestHelper loadFixture:@"extjs.html"];
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [server handleFetchedServerVersion:response];
    STAssertEqualObjects([server realVersion], @"3.5.232~g7ac5542-dirty", @"version 3.5.232~g7ac5542-dirty not correctly detected");
    STAssertEqualObjects([server version], @"34", @"version 3.5.232~g7ac5542-dirty not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend 3.5.232~g7ac5542-dirty</title>"];
    STAssertEqualObjects([server realVersion], @"3.5.232~g7ac5542-dirty", @"lonely version 3.5.232~g7ac5542-dirty not correctly detected");
    STAssertEqualObjects([server version], @"34", @"lonely version 3.5.232~g7ac5542-dirty not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend 3.4.27</title>"];
    STAssertEqualObjects([server realVersion], @"3.4.27", @"lonely version 3.4.27 not correctly detected");
    STAssertEqualObjects([server version], @"34", @"3.4.27 not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend 3.3</title>"];
    STAssertEqualObjects([server realVersion], @"3.3", @"lonely version 3.3 not correctly detected");
    STAssertEqualObjects([server version], @"34", @"3.3 not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend 3.2.444-ffff</title>"];
    STAssertEqualObjects([server realVersion], @"3.2.444-ffff", @"lonely version 3.2.444-ffff not correctly detected");
    STAssertEqualObjects([server version], @"32", @"3.2.444-ffff not detected as 3.2");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend 3.0.fe3222</title>"];
    STAssertEqualObjects([server realVersion], @"3.0.fe3222", @"lonely version 3.0.fe3222 not correctly detected");
    STAssertEqualObjects([server version], @"32", @"3.0.fe3222 not detected as 3.2");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend 2.9.x</title>"];
    STAssertEqualObjects([server realVersion], @"2.9.x", @"lonely version 3.0.fe3222 not correctly detected");
    STAssertEqualObjects([server version], @"34", @"2.9.x not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend -gt535535</title>"];
    STAssertEqualObjects([server realVersion], @"-gt535535", @"lonely version -gt535535 not correctly detected");
    STAssertEqualObjects([server version], @"34", @"-gt535535 not detected as 3.4");
    
    [server handleFetchedServerVersion:@"HTS Tvheadend -gt535535"];
    STAssertEqualObjects([server version], @"34", @"invalid not detected as 3.4");
    
    [server handleFetchedServerVersion:@""];
    STAssertEqualObjects([server version], @"34", @"empty not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>"];
    STAssertEqualObjects([server version], @"34", @"empty not detected as 3.4");
    
    [server handleFetchedServerVersion:@"HTS Tvheadend"];
    STAssertEqualObjects([server version], @"34", @"empty not detected as 3.4");
    
    [server handleFetchedServerVersion:@"</title>"];
    STAssertEqualObjects([server version], @"34", @"empty not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend</title>"];
    STAssertEqualObjects([server version], @"34", @"empty not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend </title>"];
    STAssertEqualObjects([server version], @"34", @"empty not detected as 3.4");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend 3.9.255~gbfa033d</title>"];
    STAssertEqualObjects([server realVersion], @"3.9.255~gbfa033d", @"lonely version 3.9.255~gbfa033d not correctly detected");
    STAssertEqualObjects([server version], @"40", @"3.9.255~gbfa033d not detected as 4.0");
    
    [server handleFetchedServerVersion:@"<title>HTS Tvheadend 4.0.0</title>"];
    STAssertEqualObjects([server realVersion], @"4.0.0", @"lonely version 4.0.0 not correctly detected");
    STAssertEqualObjects([server version], @"40", @"4.0.0 not detected as 4.0");
}

@end
