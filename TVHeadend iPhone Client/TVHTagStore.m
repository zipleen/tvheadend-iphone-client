//
//  TVHTagList.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHTagStore.h"
#import "TVHSettings.h"

@interface TVHTagStore()
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, weak) id <TVHTagStoreDelegate> delegate;
@end


@implementation TVHTagStore

@synthesize tags = _tags;
@synthesize delegate = _delegate;

+ (id)sharedInstance {
    static TVHTagStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHTagStore alloc] init];
    });
    
    return __sharedInstance;
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData //1
                                                         options:kNilOptions
                                                           error:&error];
    
    if( error ) {
        NSLog(@"[JSON Error]: %@", error.description);
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingTagStore:)]) {
            [self.delegate didErrorLoadingTagStore:error];
        }
        return ;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    
    
    NSEnumerator *e = [entries objectEnumerator];
    id tag;
    //for (NSEnumerator *channel in entries) {
    while (tag = [e nextObject]) {
        NSInteger enabled = [[tag objectForKey:@"enabled"] intValue];
        if( enabled ) {
        
            //NSLog(@"json : %@", channel);
            TVHTag *t = [[TVHTag alloc] init];
            
            NSInteger tagid = [[tag objectForKey:@"id"] intValue];
            NSString *name = [tag objectForKey:@"name"];
            NSString *comment = [tag objectForKey:@"comment"];
            NSString *imageUrl = [tag objectForKey:@"icon"];
            
            [t setTagid:tagid];
            [t setName:name];
            [t setComment:comment];
            [t setImageUrl:imageUrl];
            
            [tags addObject:t];
        }
    }
     
    NSMutableArray *orderedTags = [[tags sortedArrayUsingSelector:@selector(compareByName:)] mutableCopy];
    
    // All channels
    TVHTag *t = [[TVHTag alloc] initWithAllChannels];
    [orderedTags insertObject:t atIndex:0];
    
    self.tags = [orderedTags copy];
    NSLog(@"[Loaded Tags]: %d", [self.tags count]);
}

- (void)fetchTagList {
    if( [self.tags count] == 0 ) {
        TVHSettings *settings = [TVHSettings sharedInstance];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[settings baseURL] ];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"get", @"op", @"channeltags", @"table", nil];
        
        [httpClient postPath:@"/tablemgr" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self fetchedData:responseObject];
            [self.delegate didLoadTags];
            
            //NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            //NSLog(@"Request Successful, response '%@'", responseStr);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(didErrorLoadingTagStore:)]) {
                [self.delegate didErrorLoadingTagStore:error];
            }
            NSLog(@"[TagList HTTPClient Error]: %@", error.localizedDescription);
        }];
    }
}

- (TVHTagStore *) objectAtIndex:(int) row {
    return [self.tags objectAtIndex:row];
}

- (int) count {
    return [self.tags count];
}

- (void)setDelegate:(id <TVHTagStoreDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

@end
