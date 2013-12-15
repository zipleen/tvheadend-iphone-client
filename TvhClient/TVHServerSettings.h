//
//  TVHServerSetting.h
//  TvhClient
//
//  Created by zipleen on 12/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>

#define TVHS_SORT_CHANNEL_BY_NAME 0
#define TVHS_SORT_CHANNEL_BY_NUMBER 1

#define TVHS_SERVER_NAME @"ServerName"
#define TVHS_IP_KEY @"ServerIp"
#define TVHS_PORT_KEY @"ServerPort"
#define TVHS_HTSP_PORT_KEY @"ServerPortHTSP"
#define TVHS_USERNAME_KEY @"Username"
#define TVHS_PASSWORD_KEY @"Password"
#define TVHS_USE_HTTPS @"ServerUseHTTPS"
#define TVHS_SERVER_WEBROOT @"ServerWebroot"
#define TVHS_SSH_PF_HOST @"SSHPF_Host"
#define TVHS_SSH_PF_PORT @"SSHPF_Port"
#define TVHS_SSH_PF_USERNAME @"SSHPF_Username"
#define TVHS_SSH_PF_PASSWORD @"SSHPF_Password"
#define TVHS_SERVER_VERSION @"ServerVersion"

// Init with the following strings inside a NSDictionary 
#define TVHS_SERVER_KEY_SETTINGS @[TVHS_SERVER_NAME, TVHS_IP_KEY, TVHS_PORT_KEY, TVHS_HTSP_PORT_KEY, TVHS_USERNAME_KEY, TVHS_PASSWORD_KEY, TVHS_USE_HTTPS, TVHS_SERVER_WEBROOT, TVHS_SSH_PF_HOST, TVHS_SSH_PF_PORT, TVHS_SSH_PF_USERNAME, TVHS_SSH_PF_PASSWORD, TVHS_SERVER_VERSION]

#define TVHS_SSH_PF_LOCAL_PORT @48974
#define TVHS_SSH_PF_LOCAL_HTSP_PORT @48975

@interface TVHServerSettings : NSObject
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *ip;
@property (nonatomic, strong, readonly) NSString *port;
@property (nonatomic, strong, readonly) NSString *portHTSP;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic, strong, readonly) NSString *useHTTPS;
@property (nonatomic, strong, readonly) NSString *webroot;
@property (nonatomic, strong, readonly) NSString *sshPortForwardHost;
@property (nonatomic, strong, readonly) NSString *sshPortForwardPort;
@property (nonatomic, strong, readonly) NSString *sshPortForwardUsername;
@property (nonatomic, strong, readonly) NSString *sshPortForwardPassword;
@property (nonatomic, strong, readonly) NSString *version;

// "system wide" settings
@property (nonatomic) NSInteger sortChannel;
@property (nonatomic) BOOL autoStartPolling;
@property (nonatomic, strong) NSString *transcodeResolution;
@property (nonatomic, strong) NSString *customPrefix;

- (id)initWithSettings:(NSDictionary*)settings;
- (NSURL*)baseURL;
- (NSString*)httpURL;
- (NSString*)htspURL;
@end
