//
//  TVHLogStore.m
//  TvhClient
//
//  Created by Luis Fernandes on 09/03/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
