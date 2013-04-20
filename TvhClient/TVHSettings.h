//
//  TVHSettings.h
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

#import <Foundation/Foundation.h>
#define TVHS_SERVER_NAME @"ServerName"
#define TVHS_IP_KEY @"ServerIp"
#define TVHS_PORT_KEY @"ServerPort"
#define TVHS_USERNAME_KEY @"Username"
#define TVHS_PASSWORD_KEY @"Password"
#define TVHS_SSH_PF_HOST @"SSHPF_Host"
#define TVHS_SSH_PF_PORT @"SSHPF_Port"
#define TVHS_SSH_PF_USERNAME @"SSHPF_Username"
#define TVHS_SSH_PF_PASSWORD @"SSHPF_Password"

#define TVHS_SELECTED_SERVER @"SelectedServer"
#define TVHS_SERVERS @"Servers"
#define TVHS_SORT_CHANNEL @"SortChannelBy"

#define TVHS_SERVER_KEYS @[TVHS_SERVER_NAME, TVHS_IP_KEY, TVHS_PORT_KEY, TVHS_USERNAME_KEY, TVHS_PASSWORD_KEY, TVHS_SSH_PF_HOST, TVHS_SSH_PF_PORT, TVHS_SSH_PF_USERNAME, TVHS_SSH_PF_PASSWORD]
#define TVHS_SORT_CHANNEL_BY_NAME 0
#define TVHS_SORT_CHANNEL_BY_NUMBER 1

#define TVHS_SSH_PF_LOCAL_PORT @48974

@interface TVHSettings : NSObject
+ (id)sharedInstance;
@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic) NSInteger selectedServer;
@property (nonatomic) NSTimeInterval cacheTime;
@property (nonatomic) BOOL autoStartPolling;
@property (nonatomic) NSInteger sortChannel;
@property (nonatomic) BOOL sendAnonymousStatistics;
@property (nonatomic) BOOL useBlackBorders;
- (NSString*)customPrefix;
- (void)setCustomPrefix:(NSString*)customPrefix;

- (NSDictionary*)serverProperties:(NSInteger)serverId;
- (void)setServerProperties:(NSDictionary*)properties forServerId:(NSInteger)serverId;
- (NSDictionary*)newServer;
- (void)removeServer:(NSInteger)serverId;
- (NSString*)serverProperty:(NSString*)key forServer:(NSInteger)serverId;
- (NSString*)currentServerProperty:(NSString*)key;
- (NSArray*)availableServers;
- (void)resetSettings;
- (BOOL)programFirstRun;
- (void)setRemoveAds;
- (BOOL)removeAds;
- (void)setUseBlackBorders:(BOOL)useBlackBorders;
- (BOOL)useBlackBorders;

@end
