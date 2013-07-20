//
//  CommonTabController.m
//
//

#import "CommonTabController.h"
#import "PKOAppDelegate.h"

@implementation CommonTabController
@synthesize tabBarShowing, placeController;

int tick=0;

#pragma mark - init, dealloc, basic methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    // Initialize the PKORequestManager
    if (self) {
        prefs               = [NSUserDefaults standardUserDefaults];
        NSString *user_name = [prefs objectForKey:@"username"];
        NSString *apiKey    = [prefs objectForKey:@"api_key"];
        NSString *pass      = [prefs objectForKey:@"password"];
        
        requestManager = [[PKORequestManager alloc] init];
        
        [[requestManager user] setApikey:apiKey];
        [[requestManager user] setUsername:user_name];
        [[requestManager user] setPassword:pass];
        [requestManager setDelegate:self];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)onTick
{
   [self getSyncRequests];
    
    // Let all of the listening controllers perform actions according to the
    // master timer
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mastertimer" object:self];
}


- (void) stopTimer
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void) startTimer
{
    [self getSyncRequests];
    [self stopTimer];
    
    timer = [
        NSTimer scheduledTimerWithTimeInterval: 30
        target: self
        selector:@selector(onTick)
        userInfo: nil
        repeats:YES
    ];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startTimer];
    
    isFirstTime   = false;
    contactsData  = [[NSMutableString alloc]initWithString:@"[]"];
    
    // Preallocate arrays for later use
    activationQueueContacts  = [[NSMutableArray alloc] init];
    activationQueueUsernames = [[NSMutableArray alloc] init];
    activationQueuePhones    = [[NSMutableArray alloc] init];
    activationQueue          = [[NSMutableArray alloc] init];
    
    // TODO: Reorganize notification handlers elsewhere
    //       There should be some sort of class that controls these timed actions
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(startTimer)
        name:UIApplicationDidBecomeActiveNotification
        object:nil
    ];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(stopTimer)
        name:UIApplicationDidEnterBackgroundNotification
        object:nil
    ];
  
    // Setup the various views as "tabs" that can be paged through
    NSArray *tabControllers;
    
    signupController = [[SignupController alloc] init];
    placeController  = [[PlaceController alloc] init];

    // Provide the controllers with references to this controller
    [signupController setDelegate:self];
    [placeController setCommonTabController:self];
    
    // Setup reference to the contacts controller
    contactsController = [placeController contactsController];
    
    tabControllers = [NSArray arrayWithObjects: placeController, nil];
    
    [self setViewControllers:tabControllers animated:YES];
    
    // Hide the tab bar and make the frame the full screen size
    [self.tabBar setHidden:YES];
    [self.tabBar setAlpha:0.0];
    parent        = self.tabBar.superview;              // UILayoutContainerView
    content       = [parent.subviews objectAtIndex:0];  // UITransitionView
    content.frame = [[UIScreen mainScreen] bounds];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    didViewAppear = YES;
    if (![[requestManager user] apikey] || shouldShowSignup) {
        shouldShowSignup = NO;
        [self showSignupViewController];
    }
}
         
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    didViewAppear = NO;
}


#pragma mark- Update the state of the app

- (void) updateApiKey:(NSString *)apiKey
{
    [[requestManager user] setApikey:apiKey];
}

#pragma mark- Methods to switch views

- (void) showPlacesViewController
{
    if (isSignupVisible) {
        isSignupVisible = NO;
        [self dismissViewControllerAnimated:YES completion:^{}];
        [self startTimer];
    }
}

- (void) showSignupViewController
{
    if (!isSignupVisible && didViewAppear) {
        isSignupVisible = YES;
        [self presentViewController:signupController animated:YES completion:^{}];
    } else if (!isSignupVisible) {
        shouldShowSignup = YES;
    }
}


#pragma mark- HTTP Requests

// getSyncRequests method checks for new SyncRequests and alert the user.
-(void) getSyncRequests
{
    [requestManager initiateSyncRequestRetrieval];
}


#pragma mark- PKORequestManager Protocol Methods

// Bad Request
- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
    // Should not receive any 400 errors
}


// The user's api key was not valid, show the signup and login screen
- (void) requestDidReceiveForbidden
{
    [prefs setObject:0 forKey:@"loginStatus"];
    [self stopTimer];
    [self showSignupViewController];
}


// Create an alert for each sync request and prompt the user to do something
- (void) didReceiveSyncRequests:(NSDictionary *) requests
{
    // TODO: Why is this here?
    //[self getActiveContacts];
    
    // TODO: this will be a very poor experience for more than one request
    for (NSDictionary *dict in requests) {
        // Request a contact's image
        UIImage *contactPhoto = [requestManager getImageForUser:[dict objectForKey:@"user_name"]];
        
        [placeController
            showSyncRequestWithName:[NSString
                stringWithFormat:@"%@ %@",
                [dict objectForKey:@"first_name"],
                [dict objectForKey:@"last_name"]
            ]
            andImage:contactPhoto
            andUsername:[dict valueForKey:@"user_name"]
        ];
    }
}

@end
