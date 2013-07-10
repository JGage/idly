//
//  PKOAnnotation.m
//  pekko
//
//  Created by Brandon Eum on 4/8/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "PKOAnnotation.h"

@implementation PKOAnnotation

@synthesize isUser = _isUser;
@synthesize coordinate = _coordinate;
@synthesize contact = _contact;

- (id)initWithName:(NSString*)name andCoordinate:(CLLocationCoordinate2D)coordinate
{
    if ((self = [super init])) {
        _isUser = false;
        _title = [name copy];
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title
{
    NSMutableString *title = [[NSMutableString alloc] init];
    if (!_isUser) {
        [title appendString:_contact.first_name];
        [title appendFormat:@" %@", _contact.last_name];
    } else {
        [title appendString:_title];
    }

    return title;
}

- (NSString *)subtitle
{
    return @"";
}

@end
