//
//  TVHSettings.h
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#define TVHS_SERVER_NAME @"ServerName"
#define TVHS_IP_KEY @"ServerIp"
#define TVHS_PORT_KEY @"ServerPort"
#define TVHS_USERNAME_KEY @"Username"
#define TVHS_PASSWORD_KEY @"Password"
#define TVHS_USE_HTTPS @"ServerUseHTTPS"
#define TVHS_SERVER_WEBROOT @"ServerWebroot"
#define TVHS_SSH_PF_HOST @"SSHPF_Host"
#define TVHS_SSH_PF_PORT @"SSHPF_Port"
#define TVHS_SSH_PF_USERNAME @"SSHPF_Username"
#define TVHS_SSH_PF_PASSWORD @"SSHPF_Password"
#define TVHS_SERVER_VERSION @"ServerVersion"

#define TVHS_SELECTED_SERVER @"SelectedServer"
#define TVHS_SERVERS @"Servers"
#define TVHS_SORT_CHANNEL @"SortChannelBy"

#define TVHS_SERVER_KEYS @[TVHS_SERVER_NAME, TVHS_IP_KEY, TVHS_PORT_KEY, TVHS_USERNAME_KEY, TVHS_PASSWORD_KEY, TVHS_USE_HTTPS, TVHS_SERVER_WEBROOT, TVHS_SSH_PF_HOST, TVHS_SSH_PF_PORT, TVHS_SSH_PF_USERNAME, TVHS_SSH_PF_PASSWORD, TVHS_SERVER_VERSION]
#define TVHS_SORT_CHANNEL_BY_NAME 0
#define TVHS_SORT_CHANNEL_BY_NUMBER 1

#define TVHS_SPLIT_RIGHT_MENU_DYNAMIC 0
#define TVHS_SPLIT_RIGHT_MENU_STATUS 1
#define TVHS_SPLIT_RIGHT_MENU_LOG 2
#define TVHS_SPLIT_RIGHT_MENU_NONE 3

#define TVHS_SSH_PF_LOCAL_PORT @48974

@interface TVHSettings : NSObject
+ (id)sharedInstance;
@property (nonatomic, strong, readonly) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic) NSInteger selectedServer;
@property (nonatomic) BOOL autoStartPolling;
@property (nonatomic) NSInteger sortChannel;
@property (nonatomic) BOOL sendAnonymousStatistics;
@property (nonatomic) BOOL useBlackBorders;
@property (nonatomic, strong) NSString *transcodeResolution;
// ipad
@property (nonatomic) NSInteger statusSplitPosition;
@property (nonatomic) NSInteger statusSplitPositionPortrait;
@property (nonatomic) BOOL statusShowLog;
@property (nonatomic) NSInteger splitRightMenu;
@property (nonatomic, strong) NSString *web1Url;
@property (nonatomic, strong) NSString *web1User;
@property (nonatomic, strong) NSString *web1Pass;

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
- (NSString*)fullBaseURL;
@end
