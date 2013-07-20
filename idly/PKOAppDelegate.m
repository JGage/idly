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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Get a shared instance of the user and set it up
    user = [PKOUserContainer sharedContainer];
    prefs = [NSUserDefaults standardUserDefaults];
    user.apikey        = [prefs objectForKey:@"api_key"];
    user.info.username = [prefs objectForKey:@"user_name"];

    NSString *user_name = [prefs objectForKey:@"username"];
    NSString *apiKey    = [prefs objectForKey:@"api_key"];
    NSString *pass      = [prefs objectForKey:@"password"];

    // Setup the request manager
    requestManager = [[PKORequestManager alloc] init];
    [[requestManager user] setApikey:apiKey];
    [[requestManager user] setUsername:user_name];
    [[requestManager user] setPassword:pass];
    [requestManager setDelegate:self];

    // Start the timer
    [self startTimer];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"app-bg.png"]];
    
    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    //UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];

    // Initialize ahd show the place controller
    placeController = [[PlaceController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = placeController;
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self stopTimer];
    [placeController setLocationAccuracyToBackgroundLevel];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

// Set the badge number to 0 when it launches
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    [self startTimer];
    [placeController setLocationAccuracyToForegroundLevel];
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

#pragma mark - Timed Operations

- (void) stopTimer
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void) startTimer
{
    //[self getSyncRequests];
    [self stopTimer];

  timer = [
           NSTimer scheduledTimerWithTimeInterval: 30
           target: self
           selector:@selector(onTick)
           userInfo: nil
           repeats:YES
           ];
}

#pragma mark- PKORequestManager Protocol Methods

// getSyncRequests method checks for new SyncRequests and alert the user.
-(void) getSyncRequests
{
  [requestManager initiateSyncRequestRetrieval];
}

-(void)onTick
{
  [self getSyncRequests];

  // Let all of the listening controllers perform actions according to the
  // master timer
  [[NSNotificationCenter defaultCenter] postNotificationName:@"mastertimer" object:self];
}

// Bad Request
- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
  // Should not receive any 400 errors
}


// The user's api key was not valid, show the signup and login screen
- (void) requestDidReceiveForbidden
{
    [self stopTimer];
    [placeController showSignupView];
}


// Create an alert for each sync request and prompt the user to do something
- (void) didReceiveSyncRequests:(NSDictionary *) requests
{
  // TODO: this will be a very poor experience for more than one request
  //       it will just keep popping up
  for (NSDictionary *dict in requests) {
    // Request a contact's image
    UIImage *contactPhoto = [requestManager getImageForUser:[dict objectForKey:@"user_name"]];

    [placeController
     showSyncRequestWithName:[NSString
                              stringWithFormat:@"%@ %@",
                              [dict objectForKey:@"first_name"],
                              [dict objectForKey:@"last_name"]
                              ]
     andImage:contactPhoto
     andUsername:[dict valueForKey:@"user_name"]
     ];
  }
}

@end
