//
//  CommonTabController.h
//  NewWorld
//
//  Created by Rajkumar Ravi on 10/12/12.
//

#import <UIKit/UIKit.h>
#import "SignupController.h"
#import "PlaceController.h"
#import "ContactsController.h"
#import <CoreLocation/CoreLocation.h>
#import "PKORequestManager.h"

@interface CommonTabController : UITabBarController
<
    CLLocationManagerDelegate,
    UITabBarControllerDelegate,
    SignupControllerDelegate,
    PKORequestManagerDelegate
>
{
    NSUserDefaults *prefs;
    
    SignupController   *signupController;
    PlaceController    *placeController;
    ContactsController *contactsController;
    
    // All HTTP requests to the API come through the request manager
    PKORequestManager *requestManager;
    
    NSMutableArray *activationQueueContacts, *activationQueueUsernames, *activationQueuePhones, *activationQueue,*locateableContacts;
    NSMutableString *contactsData;

    UIAlertView *locationAlert;
    IBOutlet UIButton *commonBtn;
    UIButton *pullButton;
    UIImage *image;
    UIInterfaceOrientation destOrientation;
    CGPoint pullButtonCenter, tabBarCenter;
    
    UIView *parent,*content;
    NSTimer *timer;
    
    BOOL landscape;
    BOOL isFirstTime;
    BOOL isLoggedIn;
    
    BOOL didViewAppear;
    BOOL shouldShowSignup;
    BOOL isSignupVisible;
}

@property (nonatomic, readwrite) BOOL tabBarShowing;

- (void) getSyncRequests;

// Update the API Key and User Name when a person logs in or signs up
- (void) updateApiKey:(NSString *)apiKey;

// Switch between views
- (void) showSignupViewController;
- (void) showPlacesViewController;

@end

