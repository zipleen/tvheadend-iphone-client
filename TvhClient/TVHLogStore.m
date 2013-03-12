//
//  TVHLogStore.m
//  TvhClient
//
//  Created by zipleen on 09/03/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
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

- (id) init {
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDebugLogNotification:)
                                                 name:@"logmessageNotificationClassReceived"
                                               object:nil];
    return self;
}

- (void) dealloc {
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addLogLine:(NSString*) line {
    if ( [self.logLines count] > MAXLOGLINES ) {
        [self.logLines removeObjectAtIndex:0];
    }
    [self.logLines addObject:line];
}

- (void) receiveDebugLogNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"logmessageNotificationClassReceived"]) {
        NSDictionary *message = (NSDictionary*)[notification object];
        
        NSString *log = [message objectForKey:@"logtxt"];
        [self addLogLine:log];
        [self.delegate didLoadLog];
    }
}

- (NSString *) objectAtIndex:(int) row {
    if ( row < [self.logLines count] ) {
        return [self.logLines objectAtIndex:row];
    }
    return nil;
}

- (int) count {
    return [self.logLines count];
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
