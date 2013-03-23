//
//  TVHLogStore.m
//  TvhClient
//
//  Created by zipleen on 09/03/13.
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

#import "TVHLogStore.h"
#import "TVHJsonClient.h"

#define MAXLOGLINES 500

@interface TVHLogStore()
@property (nonatomic, strong) NSMutableArray *logLines;
@property (nonatomic, weak) id <TVHLogDelegate> delegate;
@end

@implementation TVHLogStore

+ (id)sharedInstance {
    static TVHLogStore *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHLogStore alloc] init];
    });
    
    return __sharedInstance;
}

- (NSMutableArray*)logLines {
    if ( ! _logLines ) {
        _logLines = [[NSMutableArray alloc] init];
    }
    return _logLines;
}

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDebugLogNotification:)
                                                 name:@"logmessageNotificationClassReceived"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetLogStore)
                                                 name:@"resetAllObjects"
                                               object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.logLines = nil;
}

- (void)resetLogStore {
    self.logLines = nil;
}

- (void)addLogLine:(NSString*) line {
    if ( [self.logLines count] > MAXLOGLINES ) {
        [self.logLines removeObjectAtIndex:0];
    }
    [self.logLines addObject:line];
}

- (void)receiveDebugLogNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"logmessageNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        NSString *log = [message objectForKey:@"logtxt"];
        [self addLogLine:log];
        [self.delegate didLoadLog];
    }
}

- (NSArray*)filteredLogLines {
    if ( !self.filter || [self.filter isEqualToString:@""] ) {
        return [self.logLines copy];
    }
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", self.filter];
    NSArray *logLinesFiltered = [self.logLines filteredArrayUsingPredicate:sPredicate];
    return logLinesFiltered;
}

- (NSString *)objectAtIndex:(int) row {
    NSArray *logLines = [self filteredLogLines];
    if ( row < [logLines count] ) {
        return [logLines objectAtIndex:[logLines count]-1-row];
    }
    return nil;
}

- (int) count {
    NSArray *logLines = [self filteredLogLines];
    return [logLines count];
}

- (void)setDelegate:(id <TVHLogDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)clearLog {
    [self.logLines removeAllObjects];
}

@end
