//
//  AppDelegate.m
//  SecondStory
//
//  Created by Jesse Scott on 2014-08-17.
//  Copyright (c) 2014 The Only Animal. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /* from http://stackoverflow.com/questions/15268702/implementing-long-running-tasks-in-background-ios */
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        
        // Wait until the pending operations finish
        [operationQueue waitUntilAllOperationsAreFinished];
        
        [application endBackgroundTask: bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    
}


@end
