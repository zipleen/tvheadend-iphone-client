//
//  TVHDvrStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 28/02/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHDvrStore.h"
#import "TVHJsonClient.h"

@interface TVHDvrStore()
@property (nonatomic, strong) NSArray *dvrItems;
@property (nonatomic, weak) id <TVHDvrStoreDelegate> delegate;
@end

@implementation TVHDvrStore
@synthesize dvrItems = _dvrItems;
@synthesize delegate = _delegate;


+ (id)sharedInstance {
    static TVHDvrStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHDvrStore alloc] init];
    });
    
    return __sharedInstance;
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:error];
    if( error ) {
        if ([self.delegate respondsToSelector:@selector(didErrorDvrStore:)]) {
            [self.delegate didErrorDvrStore:error];
        }
        return ;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *dvrItems = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHDvrItem *dvritem = [[TVHDvrItem alloc] init];
        [dvritem updateValuesFromDictionary:obj];
        
        [dvrItems addObject:dvritem];
    }];
    
    if ( [self.dvrItems count] > 0) {
        self.dvrItems = [self.dvrItems arrayByAddingObjectsFromArray:[dvrItems copy]];
    } else {
        self.dvrItems = [dvrItems copy];
    }
    
#if DEBUG
    NSLog(@"[Loaded DVR Items, Count]: %d", [self.dvrItems count]);
#endif
}

- (void)fetchDvrItemsFromServer: (NSString*)url {
    TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
    
    [httpClient getPath:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self fetchedData:responseObject];
        [self.delegate didLoadDvr];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didErrorDvrStore:)]) {
            [self.delegate didErrorDvrStore:error];
        }
#if DEBUG
        NSLog(@"[DVR Items HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
    
}

- (void)fetchDvr {
    self.dvrItems = nil;
    [self fetchDvrItemsFromServer:@"/dvrlist_upcoming"];
    [self fetchDvrItemsFromServer:@"/dvrlist_finished"];
    [self fetchDvrItemsFromServer:@"/dvrlist_failed"];
}

- (TVHDvrItem *) objectAtIndex:(int) row {
    return [self.dvrItems objectAtIndex:row];
}

- (int) count {
    return [self.dvrItems count];
}

@end
