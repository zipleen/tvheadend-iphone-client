//
//  TVHChannelStore.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/3/13.
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

#import "TVHChannelStore.h"
#import "TVHEpg.h"
#import "TVHJsonClient.h"
#import "TVHSettings.h"

@interface TVHChannelStore ()
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, weak) id <TVHChannelStoreDelegate> delegate;
@property (nonatomic, weak) TVHEpgStore *epgStore;
@property (nonatomic, strong) NSDate *lastFetchedData;
@end

@implementation TVHChannelStore 

+ (id)sharedInstance {
    static TVHChannelStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHChannelStore alloc] init];
    });
    
    return __sharedInstance;
}

- (TVHEpgStore*)epgStore {
    if(!_epgStore){
        _epgStore = [TVHEpgStore sharedInstance];
    }
    return _epgStore;
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetChannelStore)
                                                 name:@"resetAllObjects"
                                               object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.channels = nil;
    self.lastFetchedData = nil;
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary *json = [TVHJsonClient convertFromJsonToObject:responseData error:error];
    if( error ) {
        if ([self.delegate respondsToSelector:@selector(didErrorLoadingChannelStore:)]) {
            [self.delegate didErrorLoadingChannelStore:error];
        }
        return ;
    }
    
    NSArray *entries = [json objectForKey:@"entries"];
    NSMutableArray *channels = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TVHChannel *channel = [[TVHChannel alloc] init];
        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [channel setValue:obj forKey:key];
        }];
        [channels addObject:channel];

    }];
    
    if ( [[TVHSettings sharedInstance] sortChannel] == TVHS_SORT_CHANNEL_BY_NAME ) {
        self.channels =  [[channels copy] sortedArrayUsingSelector:@selector(compareByName:)];
    } else {
        self.channels =  [[channels copy] sortedArrayUsingSelector:@selector(compareByNumber:)];
    }
#ifdef TESTING
    NSLog(@"[Loaded Channels]: %d", [self.channels count]);
#endif
}

- (void)resetChannelStore {
    self.channels = nil;
    self.epgStore = nil;
    self.lastFetchedData = nil;
}

- (BOOL)isDataOld {
    if ( [self.channels count] == 0 ) {
        return YES;
    }
    if ( !self.lastFetchedData ) {
        return YES;
    }
    TVHSettings *settings = [TVHSettings sharedInstance];
    return ( [[NSDate date] compare:[self.lastFetchedData dateByAddingTimeInterval:[settings cacheTime]]] == NSOrderedDescending );
}

- (void)fetchChannelList {
    if( [self isDataOld] ) {
        TVHJsonClient *httpClient = [TVHJsonClient sharedInstance];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"list", @"op", nil];
       
        [httpClient postPath:@"/channels" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self fetchedData:responseObject];
            [self.delegate didLoadChannels];
            self.lastFetchedData = [NSDate date];
            
            [self.epgStore setDelegate:self];
            [self.epgStore downloadEpgList];
            
           // NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
           // NSLog(@"Request Successful, response '%@'", responseStr);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(didErrorLoadingChannelStore:)]) {
                [self.delegate didErrorLoadingChannelStore:error];
            }
#ifdef TESTING
            NSLog(@"[ChannelList HTTPClient Error]: %@", error.localizedDescription);
#endif
        }];
    } else {
        [self.delegate didLoadChannels];
    }
}

- (TVHChannel*)getChannelById:(NSInteger)channelId {
    NSEnumerator *e = [self.channels objectEnumerator];
    TVHChannel *channel;
    while (channel = [e nextObject]) {
        if ( [channel chid] == channelId ) {
            return channel;
        }
    }
    return nil;
}

#pragma mark EPG delegatee stuff

- (void)didLoadEpg:(TVHEpgStore*)epgStore {
    // for each epg
    NSArray *list = [epgStore epgStoreItems];
    for (TVHEpg *epg in list) {
        TVHChannel *channel = [self getChannelById:epg.channelid];
        [channel addEpg:epg];
    }
    [self.delegate didLoadChannels];
}

- (void)didErrorLoadingEpgStore:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(didErrorLoadingChannelStore:)]) {
        [self.delegate didErrorLoadingChannelStore:error];
    }
}

#pragma mark Controller delegate stuff

- (NSArray*)getFilteredChannelList {
    NSMutableArray *filteredChannels = [[NSMutableArray alloc] init];
    for (TVHChannel *channel in self.channels) {
        if( [channel hasTag:self.filterTag] ) {
            [filteredChannels addObject:channel];
        }
    }
    return [filteredChannels copy];
}

- (TVHChannel*)objectAtIndex:(int) row {
    if(self.filterTag == 0) {
        return [self.channels objectAtIndex:row];
    } else {
        NSArray *filteredTag = [self getFilteredChannelList];
        if (row < [filteredTag count]){
            return [filteredTag objectAtIndex:row];
        }
    }
    return nil;
}

- (TVHChannel*)channelWithName:(NSString*) name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *filteredArray = [self.channels filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        return [filteredArray objectAtIndex:0];
    }
    return nil;
}

- (TVHChannel*)channelWithId:(NSInteger)channelId {
    // not using a predicate because if I find one channel then I'll return it right away
    for (TVHChannel *channel in self.channels) {
        if( channel.chid == channelId ) {
            return channel;
        }
    }
    return nil;
}

- (int)count {
    if (self.filterTag == 0) {
        return [self.channels count];
    } else {
        NSArray *filteredTag = [self getFilteredChannelList];
        return [filteredTag count];
    }
}

- (void)setDelegate:(id <TVHChannelStoreDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

@end
