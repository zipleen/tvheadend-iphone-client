//
//  TVHServerSetting.m
//  TvhClient
//
//  Created by zipleen on 12/12/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHServerSettings.h"

@interface TVHServerSettings()
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation TVHServerSettings

- (id)initWithSettings:(NSDictionary*)settings
{
    NSParameterAssert(settings);
    self = [super init];
    if (self) {
        _name = [settings objectForKey:TVHS_SERVER_NAME];
        _ip = [self ipForSettings:settings];
        _port = [self portForSettings:settings];
        _portHTSP = [self portHTSPForSettings:settings];
        _username = [settings objectForKey:TVHS_USERNAME_KEY];
        _password = [settings objectForKey:TVHS_PASSWORD_KEY];
        _useHTTPS = [self useHttpsForSettings:settings];
        _webroot = [self webrootForSettings:settings];
        _sshPortForwardHost = [settings objectForKey:TVHS_SSH_PF_HOST];
        _sshPortForwardPort = [settings objectForKey:TVHS_SSH_PF_LOCAL_PORT];
        _sshPortForwardUsername = [settings objectForKey:TVHS_SSH_PF_USERNAME];
        _sshPortForwardPassword = [settings objectForKey:TVHS_SSH_PF_PASSWORD];
        _version = [settings objectForKey:TVHS_SERVER_VERSION];
    }
    return self;
}

- (NSString*)ipForSettings:(NSDictionary*)settings
{
    NSString *ip;
    if ( [[settings objectForKey:TVHS_SSH_PF_HOST] length] > 0 ) {
        ip = @"127.0.0.1";
    } else {
        ip = [settings objectForKey:TVHS_IP_KEY];
    }
    return ip;
}

- (NSString*)portForSettings:(NSDictionary*)settings
{
    NSString *port;
    if ( [[settings objectForKey:TVHS_SSH_PF_HOST] length] > 0 ) {
        port = [NSString stringWithFormat:@"%@", TVHS_SSH_PF_LOCAL_PORT];
    } else {
        port = [settings objectForKey:TVHS_PORT_KEY];
        if( [port length] == 0 ) {
            port = @"9981";
        }
    }
    return port;
}

- (NSString*)portHTSPForSettings:(NSDictionary*)settings
{
    NSString *port;
    if ( [[settings objectForKey:TVHS_SSH_PF_HOST] length] > 0 ) {
        port = [NSString stringWithFormat:@"%@", TVHS_SSH_PF_LOCAL_HTSP_PORT];
    } else {
        port = [settings objectForKey:TVHS_HTSP_PORT_KEY];
        if( [port length] == 0 ) {
            port = @"9982";
        }
    }
    return port;
}

- (NSString*)useHttpsForSettings:(NSDictionary*)settings
{
    NSString *useHttps;
    // crude hack instead of a bool, but this way I don't have to deal with different NSArray objects
    useHttps = [settings objectForKey:TVHS_USE_HTTPS];
    if ( ! ([useHttps isEqualToString:@""] || [useHttps isEqualToString:@"s"]) ) {
        useHttps = @"";
    }
    return useHttps;
}

- (NSString*)webrootForSettings:(NSDictionary*)settings
{
    NSString *webroot;
    webroot = [settings objectForKey:TVHS_SERVER_WEBROOT];
    if ( ! webroot ) {
        webroot = @"";
    }
    return webroot;
}

#pragma mark URL building

- (NSURL*)baseURL
{
    if( ! _baseURL ) {
        NSString *baseUrlString = [NSString stringWithFormat:@"http%@://%@:%@%@", self.useHTTPS, self.ip, self.port, self.webroot];
        NSURL *url = [NSURL URLWithString:baseUrlString];
        _baseURL = url;
    }
    return _baseURL;
}

- (NSString*)httpURL
{
    NSString *baseUrlString;
    if ( [self.username isEqualToString:@""] ) {
        baseUrlString = [NSString stringWithFormat:@"http%@://%@:%@%@", self.useHTTPS, self.ip, self.port, self.webroot];
    } else {
        baseUrlString = [NSString stringWithFormat:@"http%@://%@:%@@%@:%@%@", self.useHTTPS, self.username, self.password, self.ip, self.port, self.webroot];
    }
    
    return baseUrlString;
}

- (NSString*)htspURL
{
    NSString *loginCredentials = @"";
    if ( ! [self.username isEqualToString:@""] ) {
        loginCredentials = [NSString stringWithFormat:@"%@:%@@", self.username, self.password];
    }
    return [NSString stringWithFormat:@"htsp://%@%@:%@", loginCredentials, self.ip, self.portHTSP];
}

@end
