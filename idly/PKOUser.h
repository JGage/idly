//
//  PKOUser.h
//  pekko
//
//  Created by Brandon Eum on 4/8/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum UserTypes {
  NORMAL   = 0,
  PROSPECT = 1
} UserTypes;

@interface PKOUser : NSObject
{
    NSString *name, *username, *first_name, *last_name, *phone, *msg, *status, *display_status, *activation_status;
    NSNumber *icon_id, *type;
    UIImage *photo;
    
    NSMutableArray *upForActivities;
    NSMutableSet *upForActivitiesSet;
    
    CLLocationDegrees lat, lon;
    BOOL isVisible;
}


@property (nonatomic,strong) NSString *name, *username, *first_name, *last_name, *phone, *msg, *status, *display_status, *activation_status;
@property (nonatomic,strong) NSNumber *icon_id, *type;
@property (nonatomic,assign) CLLocationDegrees lat, lon;
@property (nonatomic,strong) UIImage *photo;
@property (nonatomic,strong) NSMutableArray *upForActivities;
@property(nonatomic) BOOL isVisible;

- (NSDictionary *) toDictionary;
- (NSMutableDictionary *) toDisplayUpdateDictionary;

@end
