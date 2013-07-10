//
//  PKOAppDelegate.m
//  pekko
//
//  Created by Brandon Eum on 3/3/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "PKOAppDelegate.h"

@implementation PKOAppDelegate

@synthesize window = _window;
@synthesize commonTabController=_commonTabController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Get a shared instance of the user and set it up
    user = [PKOUserContainer sharedContainer];
    prefs = [NSUserDefaults standardUserDefaults];
    user.apikey        = [prefs objectForKey:@"api_key"];
    user.info.username = [prefs objectForKey:@"user_name"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"app-bg.png"]];
    
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    self.commonTabController = [[CommonTabController alloc] initWithNibName:@"CommonTabController" bundle:nil];
    
    requestManager = [[PKORequestManager alloc] init];
    self.window.rootViewController = self.commonTabController;
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}

// Set the badge number to 0 when it launches
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {}

#pragma mark - Push Notification Handling

// Update the push ID on this user's account
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[deviceToken description] forKey:@"push_id"];
    [requestManager updateAccount:dict];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end
