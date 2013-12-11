//
//  TVHCometPollStore.h
//  TVHeadend iPhone Client
//
//  Created by Luis Fernandes on 2/21/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHCometPoll.h"

@class TVHServer;

@interface TVHCometPollAbstract : NSObject <TVHCometPoll>
- (id)initWithTvhServer:(TVHServer*)tvhServer;
- (void)fetchCometPollStatus;
- (void)toggleDebug;
- (BOOL)isDebugActive;

- (void)startRefreshingCometPoll;
- (void)stopRefreshingCometPoll;
- (BOOL)isTimerStarted;
@end
