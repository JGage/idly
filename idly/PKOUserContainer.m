//
//  PKOUserContainer.m
//
//  Created by Brandon Eum on 2/21/13.
//

#import "PKOUserContainer.h"

@implementation PKOUserContainer

@synthesize apikey, username, password, activeContacts, pendingContacts, lat, lon, statusMsg, mood;
@synthesize info, upforActivities;

// Force this class to be a singleton accessed through this static reference
+ (id) sharedContainer {
    static PKOUserContainer *sharedContainer = nil;
    
    if (!sharedContainer) {
        sharedContainer = [[super allocWithZone:nil] init];
    }
    
    return sharedContainer;
}

// Do not let anyone create an instance
+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedContainer];
}

- (id)init
{
    info            = [[PKOUser alloc] init];
    activeContacts  = [[NSMutableArray alloc] init];
    pendingContacts = [[NSMutableArray alloc] init];
    upforActivities = [[NSMutableDictionary alloc] init];

    prefs          = [NSUserDefaults standardUserDefaults];
    self.username  = [prefs objectForKey:@"username"];
    self.apikey    = [prefs objectForKey:@"api_key"];
    self.password  = [prefs objectForKey:@"password"];
    return self;
}

// set the user's password and place it into their preferences
- (void) updatePassword:(NSString *)pass
{
  self.password = pass;
  [prefs setObject:pass forKey:@"password"];
}

@end
