//
//  TVHEpgList.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/10/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHEpgList.h"
#import "TVHEpg.h"
#import "TVHSettings.h"

@interface TVHEpgList()
@property (nonatomic, strong) NSArray *epgList;
@property (nonatomic, weak) id <TVHEpgListDelegate> delegate;
@end

@implementation TVHEpgList
@synthesize epgList = _epgList;

+ (id)sharedInstance {
    static TVHEpgList *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHEpgList alloc] init];
    });
    
    return __sharedInstance;
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData //1
                                                         options:kNilOptions
                                                           error:&error];
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *epgList = [[NSMutableArray alloc] init];
    
    NSEnumerator *e = [entries objectEnumerator];
    id channel;
    //for (NSEnumerator *channel in entries) {
    while (channel = [e nextObject]) {
        //NSLog(@"json : %@", channel);
        TVHEpg *e = [[TVHEpg alloc] init];
        
        NSInteger channelId = [[channel objectForKey:@"channelid"] intValue];
        NSString *title = [channel objectForKey:@"title"];
        NSString *description = [channel objectForKey:@"description"];
        NSInteger start = [[channel objectForKey:@"start"] intValue];
        NSInteger end = [[channel objectForKey:@"end"] intValue];
        NSInteger duration = [[channel objectForKey:@"duration"] intValue];
        
        [e setChannelId:channelId];
        [e setTitle:title];
        [e setDescription:description];
        [e setDuration:duration];
        [e setStartFromInteger:start];
        [e setEndFromInteger:end];
                
        [epgList addObject:e];
    }
    self.epgList = [epgList copy];
    NSLog(@"[Loaded EPG programs]: %d", [self.epgList count]);
}

- (void)fetchEpgList {
    TVHSettings *settings = [TVHSettings sharedInstance];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[settings baseURL] ];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"start", @"300", @"limit",nil];
    
    [httpClient postPath:@"/epg" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        [self.delegate didLoadEpg];
        
        //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}

- (NSArray*)getEpgList{
    return self.epgList;
}

@end
