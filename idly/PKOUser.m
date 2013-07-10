//
//  PKOUser.m
//  pekko
//
//  Created by Brandon Eum on 4/8/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "PKOUser.h"

@implementation PKOUser
@synthesize name, username, first_name, last_name, phone, msg, photo, status, icon_id, display_status, activation_status;
@synthesize lat, lon, type;
@synthesize isVisible;
@synthesize upForActivities;

- (id) init
{
    self = [super init];
    if (self) {
        upForActivities = [[NSMutableArray alloc] init];
        upForActivitiesSet = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ : %@ : %d",username,name,isVisible];
}

- (NSDictionary *) toDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:name forKey:@"name"];
    [dict setObject:username forKey:@"username"];
    [dict setObject:first_name forKey:@"first_name"];
    [dict setObject:last_name forKey:@"last_name"];
    [dict setObject:phone forKey:@"phone"];
    
    
    if (msg && status && icon_id) {
        [dict setObject:msg forKey:@"msg"];
        [dict setObject:status forKey:@"status"];
        [dict setObject:icon_id forKey:@"icon_id"];
    }
    
    if (lat && lon) {
        [dict setObject:[NSNumber numberWithDouble:lat] forKey:@"lat"];
        [dict setObject:[NSNumber numberWithDouble:lon] forKey:@"lon"];
    }
    
    // Return an unmutable copy of the dictionary
    return dict;
}

- (NSMutableDictionary *) toDisplayUpdateDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:username forKey:@"username"];
    return dict;
}

@end
