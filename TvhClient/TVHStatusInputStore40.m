//
//  TVHStatusInputStore40.m
//  TvhClient
//
//  Created by zipleen on 10/12/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHStatusInputStore40.h"
#import "TVHServer.h"

@interface TVHStatusInputStore40()
@property (nonatomic, weak) TVHApiClient *apiClient;
@property (nonatomic, strong) NSArray *inputs;
@end

@implementation TVHStatusInputStore40

- (id)initWithTvhServer:(TVHServer*)tvhServer {
    self = [super init];
    if (!self) return nil;
    self.tvhServer = tvhServer;
    self.apiClient = [self.tvhServer apiClient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSubscriptionNotification:)
                                                 name:@"inputsNotificationClassReceived"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchStatusInputs)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.inputs = nil;
}

- (void)receiveSubscriptionNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"inputsNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        if ( [[message objectForKey:@"reload"] intValue] == 1 ) {
            [self fetchStatusInputs];
        }
        
        [self.inputs enumerateObjectsUsingBlock:^(TVHStatusInput* obj, NSUInteger idx, BOOL *stop) {
            if (  [[message objectForKey:@"uuid"] isEqualToString:obj.uuid] ) {
                [obj updateValuesFromDictionary:message];
            }
        }];
        
        [self signalDidLoadStatusInputs];
    }
}

- (BOOL)fetchedData:(NSData *)responseData {
    NSError __autoreleasing *error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:&error];
    if( error ) {
        [self signalDidErrorStatusInputStore:error];
        return false;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *inputs = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHStatusInput *statusInput = [[TVHStatusInput alloc] init];
        [statusInput updateValuesFromDictionary:obj];
        
        [inputs addObject:statusInput];
    }];
    
    self.inputs = [inputs copy];
    
#ifdef TESTING
    NSLog(@"[Loaded Status Input]: %d", [self.inputs count]);
#endif
    [TVHDebugLytics setIntValue:[self.inputs count] forKey:@"statusInput"];
    return true;
}

#pragma mark Api Client delegates

- (NSString*)apiMethod {
    return @"GET";
}

- (NSString*)apiPath {
    return @"api/status/inputs";
}

- (NSDictionary*)apiParameters {
    return nil;
}

- (void)fetchStatusInputs {
    TVHStatusInputStore40 __weak *weakSelf = self;
    
    [self signalWillLoadStatusInputs];
    [self.apiClient doApiCall:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ( [weakSelf fetchedData:responseObject] ) {
            [weakSelf signalDidLoadStatusInputs];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf signalDidErrorStatusInputStore:error];
        NSLog(@"[Status Input HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (TVHStatusInput *) objectAtIndex:(int) row {
    if ( row < [self.inputs count] ) {
        return [self.inputs objectAtIndex:row];
    }
    return nil;
}

- (int)count {
    return [self.inputs count];
}

- (void)setDelegate:(id <TVHStatusInputDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

#pragma mark Signal delegates

- (void)signalDidLoadStatusInputs {
    if ([self.delegate respondsToSelector:@selector(didLoadStatusInputs)]) {
        [self.delegate didLoadStatusInputs];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadStatusInputs"
                                                        object:self];
}

- (void)signalWillLoadStatusInputs {
    if ([self.delegate respondsToSelector:@selector(willLoadStatusInputs)]) {
        [self.delegate willLoadStatusInputs];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willLoadStatusInputs"
                                                        object:self];
}

- (void)signalDidErrorStatusInputStore:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorStatusInputStore:)]) {
        [self.delegate didErrorStatusInputStore:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didErrorStatusInputStore"
                                                        object:error];
}

@end