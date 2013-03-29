//
//  TVHSettings.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
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

#import "TVHSettings.h"
#import "TVHJsonClient.h"
#define TVHS_CACHING_TIME @"CachingTime"
#define TVHS_AUTO_START_COMET_POOL @"AutoStartCometPool"
#define TVHS_CUSTOM_PREFIX @"CustomAppPrefix"
#define TVHS_SEND_ANONSTATS @"sendAnonymousStatistics"

@interface TVHSettings()

@end

@implementation TVHSettings
@synthesize baseURL = _baseURL;
@synthesize username = _username;
@synthesize password = _password;
@synthesize selectedServer = _selectedServer;
@synthesize cacheTime = _cacheTime;
@synthesize autoStartPolling = _autoStartPolling;
@synthesize sortChannel = _sortChannel;
@synthesize sendAnonymousStatistics = _sendAnonymousStatistics;

+ (id)sharedInstance {
    static TVHSettings *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[TVHSettings alloc] init];
    });
    
    return __sharedInstance;
}

#pragma mark Servers

- (NSArray*)availableServers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *servers = [defaults objectForKey:TVHS_SERVERS];
    if (servers == nil) {
        servers = [[NSArray alloc] init];
    }
    return servers;
}

- (NSString*)serverProperty:(NSString*)key forServer:(NSInteger)serverId {
    NSArray *servers = self.availableServers;
    if ( serverId < [servers count] ) {
        NSDictionary *myServer = [servers objectAtIndex:serverId];
        return [myServer objectForKey:key];
    }
    return nil;
}

- (void)setServerProperty:(NSString*)property forServer:(NSInteger)serverId ForKey:(NSString*)key {
    NSMutableArray *servers = [self.availableServers mutableCopy];
    if ( serverId < [servers count] ) {
        NSMutableDictionary *server = [[servers objectAtIndex:serverId] mutableCopy];
        
        // set property on server and replace it in servers array
        [server setObject:property forKey:key];
        [servers replaceObjectAtIndex:serverId withObject:server];
        
        // save all servers
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:servers forKey:TVHS_SERVERS];
        [defaults synchronize];
    }
}

- (NSString*)currentServerProperty:(NSString*)key {
    return [self serverProperty:key forServer:self.selectedServer];
}

- (NSInteger)addNewServer {
    NSMutableArray *servers = [self.availableServers mutableCopy];
    NSDictionary *newServer = @{TVHS_SERVER_NAME:@"", TVHS_IP_KEY:@"", TVHS_PORT_KEY:@"", TVHS_USERNAME_KEY:@"", TVHS_PASSWORD_KEY:@""};
    
    [servers addObject:newServer];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[servers copy] forKey:TVHS_SERVERS];
    [defaults synchronize];
    
    return [servers count] - 1;
}

- (NSInteger)selectedServer {
    if ( !_selectedServer ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger selectedServer = [defaults integerForKey:TVHS_SELECTED_SERVER];
        if ( selectedServer < 0 || selectedServer >= [self.availableServers count]  ) {
            return NSNotFound;
        }
        _selectedServer = selectedServer;
    }
    return _selectedServer;
}

- (void)setSelectedServer:(NSInteger)serverId {
    if ( serverId >= 0 && serverId < [self.availableServers count] ) {
        _selectedServer = serverId;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:serverId forKey:TVHS_SELECTED_SERVER];
        [defaults synchronize];
        
        [self resetSettings];
    }
}

- (void)removeServer:(NSInteger)serverId {
    NSMutableArray *servers = [self.availableServers mutableCopy];
    [servers removeObjectAtIndex:serverId];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[servers copy] forKey:TVHS_SERVERS];
    [defaults synchronize];
    
    if ( [self.availableServers count] > 0 ) {
        NSDictionary *selectedServer = [self.availableServers objectAtIndex:self.selectedServer];
        NSInteger newSelectedServer = [servers indexOfObject:selectedServer];
        if ( newSelectedServer == NSNotFound ) {
            [self setSelectedServer:0];
        } else if ( newSelectedServer != self.selectedServer ) {
            [self setSelectedServer:newSelectedServer];
        }
    }
}

#pragma mark Properties

- (NSURL*)baseURL {
    if( !_baseURL ) {
        if ( self.selectedServer == NSNotFound ) {
            return nil;
        }
        NSString *ip = [self currentServerProperty:TVHS_IP_KEY];
        NSString *port = [self currentServerProperty:TVHS_PORT_KEY];
        if( [port isEqualToString:@""] ) {
            port = @"9981";
        }
        
        NSString *baseUrlString = [NSString stringWithFormat:@"http://%@:%@", ip, port];
        NSURL *url = [NSURL URLWithString:baseUrlString];
        _baseURL = url;
    }
    return _baseURL;
}

- (NSString*)username {
    if ( !_username ) {
        _username = [self currentServerProperty:TVHS_USERNAME_KEY];
    }
    return _username;
}

// FIX: Password in cleartext!!! NEEDS TO USE KEYCHAIN!!!!!
- (NSString*)password {
    if ( !_password ) {
        _password = [self currentServerProperty:TVHS_PASSWORD_KEY];
    }
    return _password;
}

- (void)resetSettings {
    _baseURL = nil;
    _username = nil;
    _password = nil;
    
    [[[TVHJsonClient sharedInstance] operationQueue] cancelAllOperations];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"resetAllObjects"
     object:nil];
}

- (NSTimeInterval)cacheTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval time = [defaults integerForKey:TVHS_CACHING_TIME];
    if ( time <= 0 ) {
        time = 300;
    }
    return time;
}

- (void)setCacheTime:(NSTimeInterval)time {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:time forKey:TVHS_CACHING_TIME];
}

- (BOOL)autoStartPolling {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id test = [defaults objectForKey:TVHS_AUTO_START_COMET_POOL];
    if ( test == nil ) {
        _autoStartPolling = YES;
        return _autoStartPolling;
    }
    _autoStartPolling = [defaults boolForKey:TVHS_AUTO_START_COMET_POOL];
    return _autoStartPolling;
}

- (void)setAutoStartPolling:(BOOL)autoStart {
    _autoStartPolling = autoStart;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:autoStart forKey:TVHS_AUTO_START_COMET_POOL];
    [defaults synchronize];
}

- (NSString*)customPrefix {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:TVHS_CUSTOM_PREFIX];
}

- (void)setCustomPrefix:(NSString*)customPrefix {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:customPrefix forKey:TVHS_CUSTOM_PREFIX];
    [defaults synchronize];
}

- (NSInteger)sortChannel {
    if ( !_sortChannel ) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id test = [defaults objectForKey:TVHS_SORT_CHANNEL];
        if ( test == nil ) {
            _sortChannel = TVHS_SORT_CHANNEL_BY_NAME;
        } else {
            _sortChannel = [defaults integerForKey:TVHS_SORT_CHANNEL];
        }
    }
    return _sortChannel;
}

- (void)setSortChannel:(NSInteger)sortChannel {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sortChannel forKey:TVHS_SORT_CHANNEL];
    [defaults synchronize];
    _sortChannel = sortChannel;
}

- (BOOL)sendAnonymousStatistics {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id test = [defaults objectForKey:TVHS_SEND_ANONSTATS];
    if ( test == nil ) {
        _sendAnonymousStatistics = YES;
        return _sendAnonymousStatistics;
    }
    _sendAnonymousStatistics = [defaults boolForKey:TVHS_SEND_ANONSTATS];
    return _sendAnonymousStatistics;
}

- (void)setSendAnonymousStatistics:(BOOL)sendAnonymousStatistics {
    _sendAnonymousStatistics = sendAnonymousStatistics;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:sendAnonymousStatistics forKey:TVHS_SEND_ANONSTATS];
    [defaults synchronize];
}
@end

