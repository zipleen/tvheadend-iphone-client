//
//  TVHAppDelegate.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/2/13.
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

#import "TVHAppDelegate.h"
#import "TVHSettings.h"
#import "TVHApiKeys.h"

#ifdef TVH_TESTFLIGHT_KEY
#import "TestFlight.h"
#endif
#ifdef TVH_GOOGLEANALYTICS_KEY
#import "GAI.h"
#endif

@implementation TVHAppDelegate {
    NSDate *exitTime;
}

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
        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
#ifdef TVH_TESTFLIGHT_KEY
        [TestFlight takeOff:TVH_TESTFLIGHT_KEY];
#endif
    } else {
#ifdef TVH_GOOGLEANALYTICS_KEY
        [[GAI sharedInstance] setOptOut:YES];
#endif
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    exitTime = [NSDate date];
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
    // after 15 min we to reset settings so we fetch new data
    if ( [[NSDate date] compare:[exitTime dateByAddingTimeInterval:1800]] == NSOrderedDescending ) {
        [[TVHSettings sharedInstance] resetSettings];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
