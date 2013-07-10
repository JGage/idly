//
//  PKOAppUser.m
//  pekko
//
//  Created by Brandon Eum on 4/8/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "PKOAppUser.h"

@implementation PKOAppUser

- (id) init
{
    self = [super init];
    if (self) {
        activeContacts = [[NSMutableArray alloc] init];
        pendingContacts = [[NSMutableArray alloc] init];
    }
    
    return self;
}
@end
