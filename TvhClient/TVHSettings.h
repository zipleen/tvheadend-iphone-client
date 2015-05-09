//
//  TVHSettings.h
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/9/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import "TVHServerSettings.h"

#define TVHS_SPLIT_RIGHT_MENU_DYNAMIC 0
#define TVHS_SPLIT_RIGHT_MENU_STATUS 1
#define TVHS_SPLIT_RIGHT_MENU_LOG 2
#define TVHS_SPLIT_RIGHT_MENU_NONE 3

@interface TVHSettings : NSObject
+ (id)sharedInstance;
@property (nonatomic, strong) TVHServerSettings *currentServerSettings;
@property (nonatomic) NSInteger sortChannel;
@property (nonatomic) BOOL autoStartPolling;
@property (nonatomic, strong) NSString *transcodeResolution;
@property (nonatomic, strong) NSString *transcodeVideo;
@property (nonatomic, strong) NSString *transcodeSound;
@property (nonatomic, strong) NSString *transcodeMux;
@property (nonatomic, strong) NSString *customPrefix;

@property (nonatomic) NSInteger selectedServer;
@property (nonatomic) BOOL sendAnonymousStatistics;
@property (nonatomic) BOOL useBlackBorders;
// ipad
@property (nonatomic) NSInteger statusSplitPosition;
@property (nonatomic) NSInteger statusSplitPositionPortrait;
@property (nonatomic) BOOL statusShowLog;
@property (nonatomic) NSInteger splitRightMenu;
@property (nonatomic, strong) NSString *web1Url;
@property (nonatomic, strong) NSString *web1User;
@property (nonatomic, strong) NSString *web1Pass;

- (NSString*)currentServerProperty:(NSString*)key;
- (NSString*)serverProperty:(NSString*)key forServer:(NSInteger)serverId;
- (NSInteger)setServerProperties:(NSDictionary*)properties forServerId:(NSInteger)serverId;
- (NSDictionary*)serverProperties:(NSInteger)serverId;

- (NSArray*)availableServers;
- (NSDictionary*)newServer;
- (void)removeServer:(NSInteger)serverId;

- (void)resetSettings;
- (BOOL)programFirstRun;
@end
