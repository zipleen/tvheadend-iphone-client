//
//  TVHEpgStoreTests.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/16/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpgStoreTests.h"
#import "TVHEpgStore.h"

@interface TVHEpgStore (MyPrivateMethodsUsedForTesting)
@property (nonatomic, strong) NSArray *epgList;
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

-(NSData *)loadFixture:(NSString *)name
{
    NSBundle *unitTestBundle = [NSBundle bundleForClass:[self class]];
    NSString *pathForFile    = [unitTestBundle pathForResource:name ofType:nil];
    NSData   *data           = [[NSData alloc] initWithContentsOfFile:pathForFile];
    return data;
}

- (void)testJsonCharacterBug
{
    NSData *data = [self loadFixture:@"Log.287"];
    TVHEpgStore *tvhe = [TVHEpgStore sharedInstance];
    STAssertNotNil(tvhe, @"creating tvepg store object");
    [tvhe fetchedData:data];
    STAssertTrue( ([tvhe.epgList count] == 1), @"Failed parsing json data");
}

@end
