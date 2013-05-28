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
@end

@implementation TVHLogStore

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
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [self signalDidLoadLog];
    }
}

- (NSArray*)filteredLogLines {
    if ( !self.filter || [self.filter length] == 0 ) {
        return [self.logLines copy];
    }
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", self.filter];
    NSArray *logLinesFiltered = [self.logLines filteredArrayUsingPredicate:sPredicate];
    return logLinesFiltered;
}

- (NSArray*)arrayLogLines {
    return [self filteredLogLines];
}

- (void)clearLog {
    [self.logLines removeAllObjects];
}

- (void)setDelegate:(id <TVHLogDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
    }
}

- (void)signalDidLoadLog {
    if ([self.delegate respondsToSelector:@selector(didLoadLog)]) {
        [self.delegate didLoadLog];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didLoadLog"
                                                        object:self];
}

@end
