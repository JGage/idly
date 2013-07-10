//
//  PKOUserContainer.h
//  NewWorld
//
//  Created by Brandon Eum on 2/21/13.
//  Copyright (c) 2013 SriSeshaa Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "PKOUser.h"

@interface PKOUserContainer : NSObject
{
    NSUserDefaults *prefs;
  
    NSString *apikey;
    NSString *username;
    NSString *password;
    
    NSString *status_msg;
    NSString *mood;
    NSMutableDictionary *upforActivities;
    
    NSMutableArray *activeContacts;
    NSMutableArray *pendingContacts;
    
    CLLocationDegrees lat;
    CLLocationDegrees lon;
    
    // TODO: Slowly migrate all of the user information into PKOContact
    // TODO: Create a PKOUser class and have PKOContact extend it
    PKOUser *info;
}

@property (nonatomic, strong) PKOUser *info;
@property (nonatomic, strong) NSString *apikey, *username, *password, *statusMsg, *mood;
@property (nonatomic, strong) NSMutableArray *activeContacts, *pendingContacts;
@property (nonatomic, assign) CLLocationDegrees lat, lon;
@property (nonatomic, strong) NSMutableDictionary *upforActivities;

// Accessor for the shared user container singleton
+ (id) sharedContainer;

- (void) updatePassword:(NSString *)pass;

@end
