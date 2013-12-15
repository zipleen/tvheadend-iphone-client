//
//  TVHAnalytics.m
//  TvhClient
//
//  Created by Luis Fernandes on 24/10/13.
//  Copyright (c) 2013 Luis Fernandes.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAnalytics.h"
#ifdef TVH_GOOGLEANALYTICS_KEY
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#endif

@implementation TVHAnalytics

+ (void)start {
#ifdef TVH_GOOGLEANALYTICS_KEY
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 60;
#ifdef TESTING
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] setDryRun:YES];
#endif
    [[GAI sharedInstance] trackerWithTrackingId:TVH_GOOGLEANALYTICS_KEY];
    [[GAI sharedInstance].defaultTracker send:[
                                               [
                                                [GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                                                       action:@"appstart"
                                                                                        label:nil
                                                                                        value:nil]
                                                set:@"start" forKey:kGAISessionControl]
                                               build]];
#endif
}

+ (void)setOptOut:(BOOL)optOut {
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance] setOptOut:optOut];
#endif
}

+ (void)sendView:(NSString*)message {
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:message];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView]  build]];
#endif
    [TVHDebugLytics setObjectValue:message forKey:@"view"];
}

+ (void)sendEventWithCategory:(NSString *)category
                   withAction:(NSString *)action
                    withLabel:(NSString *)label
                    withValue:(NSNumber *)value {
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder
                                                createEventWithCategory:category
                                                action:action
                                                label:label
                                                value:value] build]];
#endif
}

+ (void)sendTimingWithCategory:(NSString *)category
                     withValue:(NSTimeInterval)time
                      withName:(NSString *)name
                     withLabel:(NSString *)label {
#ifdef TVH_GOOGLEANALYTICS_KEY
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder
                                                createTimingWithCategory:category
                                                interval:[NSNumber numberWithDouble:time]
                                                name:name
                                                label:label] build]];
#endif
}

@end
