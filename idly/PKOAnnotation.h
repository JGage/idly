//
//  PKOAnnotation.h
//  pekko
//
//  Created by Brandon Eum on 4/8/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "PKOContact.h"

@interface PKOAnnotation : NSObject <MKAnnotation>
{
    PKOContact *_contact;
    NSString *_title;
    CLLocationCoordinate2D _coordinate;
    BOOL _isUser;
}

@property (nonatomic, assign) BOOL isUser;
@property (nonatomic, strong) PKOContact *contact;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)name andCoordinate:(CLLocationCoordinate2D)coordinate;

- (NSString *) title;
- (NSString *) subtitle;
@end
