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


#import "PlaceController.h"


@interface PKOAppDelegate : UIResponder <UIApplicationDelegate, PKORequestManagerDelegate>
{
    NSUserDefaults *prefs;
    PKORequestManager *requestManager;
    PKOUserContainer *user;
    NSTimer *timer;
  PlaceController *placeController;
}

@property (strong, nonatomic) UIWindow *window;

- (void) onTick;
- (void) startTimer;
- (void) stopTimer;
- (void) getSyncRequests;
@end
