//
//  PKOAppUser.h
//  pekko
//
//  Created by Brandon Eum on 4/8/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "PKOUser.h"

@interface PKOAppUser : PKOUser
{
    NSMutableArray *activeContacts;
    NSMutableArray *pendingContacts;
    
}
@end
