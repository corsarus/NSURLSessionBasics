//
//  AppDelegate.m
//  NSURLSessionBasics
//
//  Created by admin on 05/12/14.
//  Copyright (c) 2014 corsarus. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // The background fetch interval is the minimum allowed by the system
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSDictionary *userInfo = @{@"backgroundFetchCompletionHandler": completionHandler};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backgroundFetchNotification" object:nil userInfo:userInfo];
}

@end
