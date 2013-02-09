//
//  ModelChannelList.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHChannelList.h"
#import "TVHSettings.h"

@interface TVHChannelList ()
@property (nonatomic, strong) NSArray *channelNames;
@property (nonatomic, weak) id <TVHChannelListDelegate> delegate;
@end

@implementation TVHChannelList
@synthesize channelNames = _channelNames;
@synthesize delegate = _delegate;

+ (id)sharedInstance {
    static TVHChannelList *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHChannelList alloc] init];
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
    NSMutableArray *channelNames = [[NSMutableArray alloc] init];
    
    NSEnumerator *e = [entries objectEnumerator];
    id channel;
    //for (NSEnumerator *channel in entries) {
    while (channel = [e nextObject]) {
        //NSLog(@"json : %@", channel);
        TVHChannel *c = [[TVHChannel alloc] init];
        
        NSString *ch_icon = [channel objectForKey:@"ch_icon"];
        NSString *name = [channel objectForKey:@"name"];
        NSString *number = [channel objectForKey:@"number"];
        
        [c setName:name];
        [c setNumber:number];
        [c setImageUrl:ch_icon];
        
        [channelNames addObject:c];
    }
    self.channelNames = [channelNames copy];
    
}


- (void)startGetTestData {
    TVHSettings *settings = [TVHSettings sharedInstance];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[settings baseURL] ];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"list", @"op", nil];
    
   [httpClient postPath:@"/channels" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        [self.delegate didLoadChannels];
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Request Successful, response '%@'", responseStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}

- (TVHChannel *) objectAtIndex:(int) row {
    return [self.channelNames objectAtIndex:row];
}

- (int) count {
    return [self.channelNames count];
}

- (void)setDelegate:(id <TVHChannelListDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

@end
