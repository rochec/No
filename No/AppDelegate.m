//
//  AppDelegate.m
//  No
//
//  Created by Chris Roche on 6/20/14.
//  Copyright (c) 2014 Chris Roche. All rights reserved.
//

#import "AppDelegate.h"
#import "NoViewController.h"
#import "UserNameTableViewController.h"

#import <iAd/iAd.h>
#import <Parse/Parse.h>

@interface AppDelegate () <UINavigationControllerDelegate>


@end

@implementation AppDelegate
{
    bool _firstTime;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"8QTzs2lrBwlEunCiprL9YJKTxbVR1yrUczlKMDRZ"
                  clientKey:@"1HsIQgbrMzR9wSZ7JB9lbLHk9ip6tQTOAJ40DgBW"];
    
        //[UIViewController prepareInterstitialAds];

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSDictionary *defaults = @{@"FirstTime": @YES,
                               @"nosReceived" : @0};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
   
    _firstTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
    
    if (_firstTime)
    {
        UITableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"registerUser"];
        self.window.rootViewController = controller;
        [self.window makeKeyAndVisible];
        
    }
    else
    {
        UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"noView"];
        self.window.rootViewController = controller;
        [self.window makeKeyAndVisible];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeAlert |
      UIRemoteNotificationTypeSound)];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    
    NSInteger nosReceived = [[NSUserDefaults standardUserDefaults] integerForKey:@"nosReceived"];
    nosReceived++;
    [[NSUserDefaults standardUserDefaults] setObject:@(nosReceived) forKey:@"nosReceived"];
    
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSArray *cellTitles = [[NSUserDefaults standardUserDefaults] arrayForKey:@"cellTitles"];
    
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)[cellTitles count] - 3];
    NSDictionary *dimensions = @{@"friends": count};
    
    [PFAnalytics trackEvent:@"numberOfFriends" dimensions:dimensions];
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
