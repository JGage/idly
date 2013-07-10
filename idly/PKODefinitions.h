//
//  PKODefinitions.h
//  pekko
//
//  Created by Brandon Eum on 4/7/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PKOContact.h"

typedef void (^PKOGenericCallback)(void);
typedef void (^PKOContactCallback)(id contact);

@interface PKODefinitions : NSObject

@end
