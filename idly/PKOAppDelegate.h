//
//  PKOAppDelegate.h
//  pekko
//
//  Created by Brandon Eum on 3/3/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PKORequestManager.h"
#import "PKOUserContainer.h"


#import "CommonTabController.h"


@interface PKOAppDelegate : UIResponder <UIApplicationDelegate>
{
    NSUserDefaults *prefs;
    PKORequestManager *requestManager;
    PKOUserContainer *user;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CommonTabController *commonTabController;

@end
