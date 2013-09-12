//
//  TVHAppDelegate.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/2/13.
//  Copyright 2013 Luis Fernandes
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "TVHAppDelegate.h"
#import "TVHSettings.h"
#import "TVHApiKeys.h"

#ifdef TVH_TESTFLIGHT_KEY
#import "TestFlight.h"
#import "AFHTTPRequestOperationLogger.h"
#endif

@implementation TVHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef TVH_GOOGLEANALYTICS_KEY
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    [GAI sharedInstance].dispatchInterval = 60;
    [GAI sharedInstance].debug = NO;
#ifdef TESTING
    [GAI sharedInstance].debug = NO;
#endif
    [[GAI sharedInstance] trackerWithTrackingId:TVH_GOOGLEANALYTICS_KEY];
    [GAI sharedInstance].defaultTracker.useHttps = YES;
#endif
    
    BOOL sendAnonymousStats = [[TVHSettings sharedInstance] sendAnonymousStatistics];
    if ( sendAnonymousStats ) {
#if defined TESTING && defined TVH_TESTFLIGHT_KEY
        //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
#if defined TESTING && defined TVH_TESTFLIGHT_KEY
        [TestFlight takeOff:TVH_TESTFLIGHT_KEY];
        [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
#endif
    } else {
#ifdef TVH_GOOGLEANALYTICS_KEY
        [[GAI sharedInstance] setOptOut:YES];
#endif
    }
#if defined TVH_CRASHLYTICS_KEY && !defined TESTING
    [Crashlytics startWithAPIKey:TVH_CRASHLYTICS_KEY];
#endif

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
