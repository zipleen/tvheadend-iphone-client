//
//  ModelChannelList.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHModelChannelList.h"
#import "TVHSettings.h"
#import "TVHChannelListViewController.h"

@interface TVHModelChannelList ()
@property (strong, nonatomic) NSArray *channelNames;
@property (weak, nonatomic) TVHChannelListViewController *sender;
@end

@implementation TVHModelChannelList
@synthesize channelNames = _channelNames;


+ (id)sharedInstance {
    static TVHModelChannelList *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHModelChannelList alloc] init];
    });
    
    return __sharedInstance;
}

- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
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
    NSURL *url = [NSURL URLWithString:@"channels" relativeToURL:[settings baseURL]];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"list", @"op", nil];
    NSData *postData = [self encodeDictionary:postDict];
    
    // Create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         // do something useful
         if (error) {
             // Deal with your error
             if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                 NSLog(@"HTTP Error: %d %@", httpResponse.statusCode, error);
                 return;
             }
             NSLog(@"Error %@", error);
             return;
         }
         
         //NSString *responeString = [[NSString alloc] initWithData:receivedData
         //                                                encoding:NSUTF8StringEncoding];
         //NSLog(@"received: %@", responeString);
         
         [self fetchedData:data];
         [self.sender reload];
     }];
    
    }

- (TVHChannel *) objectAtIndex:(int) row {
    return [self.channelNames objectAtIndex:row];
}

- (int) count {
    return [self.channelNames count];
}


- (void) setDelegate: (TVHChannelListViewController*)sender {
    self.sender = sender;
}
@end
