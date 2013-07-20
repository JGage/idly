/**
 * Place Controller
 *
 * Controls the google maps web view
 */
#import "PlaceController.h"

@implementation PlaceController

@synthesize commonTabController, contactsController;

int btn=0;
NSString *str;

int moodViewTag = 157;

#pragma mark- Init and Dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UITabBarItem *tab=[[UITabBarItem alloc]initWithTitle:@"Places" image:[UIImage imageNamed:@"places-icon2.png"] tag:0];
        
        [self setTabBarItem:tab];
        
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
        
        user = [PKOUserContainer sharedContainer];
        
        allAnnotations = [[NSMutableArray alloc] init];
        
        statusMessageController = [[StatusMessageController alloc] init];
        [statusMessageController setPlaceController:self];
        
        upForController = [[UpForController alloc] init];
        
        contactsController = [[ContactsController alloc] init];
        [contactsController setDelegate:self];
        
        outOfRangeMaskController = [[OutOfRangeMaskController alloc] init];
        outOfRangeTableController = [[OutOfRangeTableController alloc] init];
        
        // Create the contact action menu controller
        contactActionMenuController = [[ContactActionMenuController alloc] init];
        [contactActionMenuController setDelegate:self];
        
        // Settings info controller
        settingsController = [[SettingsController alloc] init];
        
        // TODO: Does this really belong in this class? Probably not...
        // Setup the location manager
        locationManager                = [[CLLocationManager alloc] init];
        locationManager.delegate       = self;
        locationManager.distanceFilter = 100;
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        // Recenter the map on the initial load
        isFirstLocationUpdate = YES;
        
        // Initiate request to get account info
        [requestManager initiateMyAccountInfoRetrieval];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- UIViewController Protocol


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the size of the view appropriately
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.view.frame = screenRect;
    
    // Initialize the StatusMessage sub view - Above the window frame (out of sight)
    UIView *sView = statusMessageController.view;
    [sView setFrame:CGRectMake(0, (-1 * sView.frame.size.height), sView.frame.size.width, sView.frame.size.height)];
    [self.view addSubview:statusMessageController.view];
    [self.view addSubview:upForController.view];
    [self.view addSubview:outOfRangeMaskController.view];
    [self.view addSubview:outOfRangeTableController.view];
    
    // Add the view in the right position, but hidden
    UIView *contactsView = contactsController.view;
    [contactsView setHidden:YES];
    [self.view addSubview:contactsView];
    
    // Add the pending request view
    pendingAlertController = [[PendingRequestAlertController alloc] init];
    [pendingAlertController setParentController:self];
    [self.view addSubview:pendingAlertController.view];
    
    // Add the contact action menu
    [self.view addSubview:contactActionMenuController.view];
    
    // Add the settings menu view
    [self.view addSubview:settingsController.view];
    
    // Get the status of the user
    shouldShowStatus = NO;
    [requestManager initiateMyStatusRetrieval];
    
    // Set the delegate of the map view
    [_mapView setDelegate:self];
}

- (void) viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D zoomLocation;
    
    if (actionMenuSubject) {
        zoomLocation.latitude  = actionMenuSubject.lat;
        zoomLocation.longitude = actionMenuSubject.lon;
    } else if (user.lat && user.lon) {
        zoomLocation.latitude  = user.lat;
        zoomLocation.longitude = user.lon;
    } else {
        isFirstLocationUpdate  = YES;
        zoomLocation.latitude  = 0;
        zoomLocation.longitude = 0;
    }


    [self setLocationAccuracyToForegroundLevel];
    // Change the view to some random location
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    //MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    //[_mapView setRegion:adjustedRegion animated:YES];
    return;
}

- (void) viewDidAppear:(BOOL)animated
{
    [locationManager startUpdatingLocation];
    [contactsController getActiveContacts];

    // Check if the address book is enabled and trigger the modal
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
      ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        // Should hide the sync button if access is not granted
      });
    }
}

#pragma mark- CLLocation Delegate methods

- (void) setLocationAccuracyToBackgroundLevel
{
  [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
}

- (void) setLocationAccuracyToForegroundLevel
{
  [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
}

// gets current location from user device
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied) {
        UIAlertView *locationAlert = [[UIAlertView alloc]
             initWithTitle:@"Location Service"
                   message:@"Enable Location services?"
                  delegate:self
         cancelButtonTitle:@"OK"
         otherButtonTitles:@"Cancel",nil
         ];
        [locationAlert show];
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
    } else {
        // TODO: Do something intelligent if location services are disabled
    }
    
}


// The location manager will update the map with the user's location
// and update their location on the server
- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation
{
    [user setLat:newLocation.coordinate.latitude];
    [user setLon:newLocation.coordinate.longitude];
    
    // Update location on the map
    [self updateLocation];
    
    if (newLocation != oldLocation && [user apikey]) {
        // Update the user's location on the backend if it has changed
        [requestManager updateLocationWithLatitude:[user lat] withLongitude:[user lon]];
    }
}


#pragma mark- Map View Updates

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self updateOutOfRangeList];
}

- (void) recenterMapWithLatitude:(CLLocationDegrees)latitude
                    andLongitude:(CLLocationDegrees)longitude
{
    if (!_mapView) {
        return;
    }
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = latitude;
    zoomLocation.longitude= longitude;
    
    // TODO: Need to figure out a way to preserve the user's zoom level
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    
    [_mapView setRegion:adjustedRegion animated:YES];
}

// update the location in the map in two ways just in case the map is not already
// initialized
- (void) updateLocation
{
    for (PKOAnnotation *annotation in _mapView.annotations) {
        if (annotation.isUser) {
            [_mapView removeAnnotation:annotation];
            break;
        }
    }
    
    // TODO: Add better annotations
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [user lat];
    zoomLocation.longitude= [user lon];
    
    userAnnotation = [[PKOAnnotation alloc] initWithName:@"hello" andCoordinate:zoomLocation];
    [userAnnotation setIsUser:YES];
    [_mapView addAnnotation:userAnnotation];
    
    PKOContact *userContact = [[PKOContact alloc] init];
    [userContact setName:@"Me"];
    [userContact setLat:[user lat]];
    [userContact setLon:[user lon]];
    [userAnnotation setContact:userContact];
    
    if (isFirstLocationUpdate && [user lat] != 0) {
        isFirstLocationUpdate = NO;
        [self recenterMapWithLatitude:[user lat] andLongitude:[user lon]];
    }
}

 
- (void) updateOutOfRangeList
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    MKMapRect visibleMapRect = _mapView.visibleMapRect;
    NSSet *visibleAnnotations = [_mapView annotationsInMapRect:visibleMapRect];
    
    PKOAnnotation *userAnn;
    
    // Loop through all of the annotations and pick out the ones that are not
    // visible
    for (PKOAnnotation *ann in _mapView.annotations) {
        if (ann.isUser) {
            userAnn = ann;
            
        // Only include contacts in the out of range view if they have a location
        } else if (ann.contact.lat && ann.contact.lat != 0 && ![visibleAnnotations containsObject:ann]) {
            [contacts addObject:ann.contact];
        }
    }
    
    // Add this user last
    if (userAnn && ![visibleAnnotations containsObject:userAnn]) {
        outOfRangeCount.text = @"Me";
        isUserOutOfRange = YES;
        return;
    } else {
        isUserOutOfRange = NO;
    }
    
    // The user object is always in the list, so make sure the count is only
    // counting the out of range contacts
    int cnt = [contacts count];
    outOfRangeCount.text = [NSString stringWithFormat:@"%i", cnt];
    
    // Empty and re-add all of the out-of-range contacts
    [outOfRangeTableController reloadContacts:contacts];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView
             viewForAnnotation:(id<MKAnnotation>)annotation
{
    PKOAnnotation *ann = (PKOAnnotation *)annotation;
    NSString *identifier;
    NSString *mood;
    if (ann.isUser) {
        identifier = @"user";
        mood = (user.mood) ? user.mood : @"happy";
    } else {
        identifier = (ann.contact.status) ? ann.contact.status : @"happy";
        mood = identifier;
    }
    
    
    MKAnnotationView *mkview = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!mkview) {
        mkview = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    mkview.annotation = ann;
    
    CustomAnnotationView *annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    annotationView.annotation = ann;
    
    // Use the mood indicator instead of the default image
    NSMutableString *img = [[NSMutableString alloc] init];
    [img appendFormat:@"%@.png", mood];
    UIImage *i = [UIImage imageNamed:img];
    [annotationView setMood:i];
    
    // Hide the picture and the frame if this is the user
    UIImageView *pic = [annotationView getPic];
    if (ann.isUser) {
        pic.hidden   = YES;
        [annotationView hideFrame];
     
    } else if (ann.contact.photo) {
        pic.image = ann.contact.photo;
        pic.hidden = NO;
        [annotationView showFrame];
    } else {
        pic.image = [UIImage imageNamed:@"user-pic.png"];
        [annotationView showFrame];
    }
    
    
    // Try something else
    

    mkview.image = i;
    [mkview addSubview:annotationView];
    
    // Do not allow callouts
    mkview.enabled        = YES;
    mkview.canShowCallout = NO;
    
    return mkview;
//    return annotationView;
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    PKOAnnotation *ann = view.annotation;
    
    // Allow the user to select their own mood
    if (ann.isUser) {
        view.selected = NO;
        view.enabled  = YES;
        [self showMoodController];
        return;
    }
    
    // Else, show the contact menu with a mask over the screen that will hide the
    // menu if the user taps outside the area

    actionMenuSubject  = ann.contact;
    selectedAnnotation = ann;
    [self showContactActionMenuWithContact:ann.contact];
}

- (void) showContactActionMenuWithContact: (PKOContact *) contact
{
    [self hideButtons];
    
    PKOAnnotation *ann = selectedAnnotation;
    
    if (ann) {
        [self recenterMapWithLatitude:ann.contact.lat andLongitude:ann.contact.lon];
    }
    
    
    [outOfRangeMaskController showWithCallback:^{
        isOutOfRangeMaskVisible = NO;
        [self showButtons];
        
        // Hide the Contact Action Menu
        [contactActionMenuController hideWithCallback:^{}];
        
        // Set the current contact to nil
        actionMenuSubject = nil;
        
        // Deselect the annotation
        if (ann) {
            [_mapView deselectAnnotation:ann animated:NO];
            selectedAnnotation = nil;
        }
    }];
    
    [contactActionMenuController showWithContact:contact];
}


- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    // Nothing to do yet
}

- (void) refreshAnnotations
{
    NSArray *annotations = [_mapView annotations];
    for (PKOAnnotation *ann in annotations) {
        [_mapView removeAnnotation:ann];
    }
    
    [_mapView addAnnotations:annotations];
}

#pragma mark- UI Interactions

- (void) hideButtons
{
    [UIView animateWithDuration:0.5
        animations:^{
            [msgButton setAlpha:0];
            [settingsButton setAlpha:0];
            [contactsButton setAlpha:0];
            [outOfRangeCountButton setAlpha:0];
            [outOfRangeCount setAlpha:0];
        }
        completion:^(BOOL finished) {
            [msgButton setHidden:YES];
            [settingsButton setHidden:YES];
            [contactsButton setHidden:YES];
            [outOfRangeCountButton setHidden:NO];
            [outOfRangeCount setHidden:NO];
        }
    ];
}

- (void) showButtons
{
    [msgButton setHidden:NO];
    [settingsButton setHidden:NO];
    [contactsButton setHidden:NO];
    [outOfRangeCountButton setHidden:NO];
    [outOfRangeCount setHidden:NO];

    [UIView animateWithDuration:0.25
         animations:^{
             [msgButton setAlpha:1];
             [settingsButton setAlpha:1];
             [contactsButton setAlpha:1];
             [outOfRangeCountButton setAlpha:1];
             [outOfRangeCount setAlpha:1];
         }
         completion:^(BOOL finished) {
             [self refreshAnnotations];
         }
    ];
}

// There was a sync request, show it on the screen as an alert
- (void) showSyncRequestWithName:(NSString *)name
                        andImage:(UIImage *)img
                     andUsername:(NSString *)username
{
    // TODO: Make this smarter by storing a queue of requests
    [self hideButtons];
    
    [pendingAlertController setRequestUsername:username];
    [[pendingAlertController nameLabel] setText:name];
    [[pendingAlertController imageView] setImage:img];
    
    // Provide a callbakt that will show the buttons when the popup is done
    [pendingAlertController showWithCallback:^{
        [self showButtons];
    }];
}


// Show the message editor by sliding into view
- (IBAction) messageButtonClicked:(id)sender
{
    // Should set the status message with the latest message
    // Initiate the request and show it once the request returns
    shouldShowStatus = YES;
    [requestManager initiateMyStatusRetrieval];
}

// Show the settings menu with the map mask
- (IBAction) settingsButtonClicked:(id)sender
{
    [self hideButtons];
    
    [outOfRangeMaskController showWithCallback:^{
        isOutOfRangeMaskVisible = NO;
        [self showButtons];
        
        // Hide the Contact Action Menu
        [settingsController hideWithCallback:^{}];
    }];

    [settingsController showView];
}

// Show the contacts menu
- (void) contactsButtonClicked:(id)sender
{
    [self hideButtons];
    [contactsController showView];
}

// Show the out of range table
- (IBAction) outOfRangeCountButtonClicked:(id)sender
{
    // If the user is out of range, refocus the map on the user
    if (isUserOutOfRange) {
        [self recenterMapWithLatitude:user.lat andLongitude:user.lon];
        return;
    }
    
    [self hideButtons];
    
    isOutOfRangeMaskVisible = YES;
    isOutOfRangeTableVisible = YES;
    
    [outOfRangeMaskController showWithCallback:^{
        isOutOfRangeMaskVisible = NO;
        [self showButtons];

        // Hide the table if it is visible
        if (isOutOfRangeTableVisible) {
            [outOfRangeTableController hideWithContact:nil];
        }
    }];
    
    [outOfRangeTableController showWithCallback:^(id contact) {
        isOutOfRangeTableVisible = NO;

        // If this one is called first, dismiss the out of range mask
        if (isOutOfRangeMaskVisible) {
            [outOfRangeMaskController hide];
        }
        
        // Loop through all of the annotations and find the one for this contact
        // Recenter the map on that contact
        if (contact) {
            PKOContact *ctc = (PKOContact *)contact;
            [self recenterMapWithLatitude:ctc.lat andLongitude:ctc.lon];
        }
    }];
}

// The user clicked their own status icon in the view
- (void) showMoodController
{
    [self hideButtons];
    
    moodController = [[MoodController alloc] init];
    [moodController setDelegate:self];
    moodController.view.tag = moodViewTag;
    [self.view addSubview:moodController.view];
    [moodController showView];
}

- (void) hideMoodController
{
    [moodController hideViewWithCallback:^{}];
}

- (void) didDismissStatusMessageView
{
    [self showButtons];
}

- (void) didDismissContactsView
{
    [self showButtons];
}

#pragma mark- Sending SMS

- (void) showSMSView:(PKOContact *)contact
{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.delegate = self;
    if([MFMessageComposeViewController canSendText]) {
        controller.body = @"\nSent via Pekko";
        controller.recipients = [[NSArray alloc] initWithObjects:contact.phone, nil];
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:^{}];
    }
}


// sending sms to users
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
	[self dismissViewControllerAnimated:YES completion:^{}];
}


- (void) showPhoneView:(PKOContact *)contact
{
    NSString *phoneUrl = [NSString stringWithFormat:@"tel://%@", contact.phone];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: phoneUrl]];
}

#pragma mark - Contact Controller Delegate

- (void) didSelectContact:(PKOContact *)contact
{
    // Show the details for the selected annotation
    PKOAnnotation *targetAnn = nil;
    NSArray *annotations = [_mapView annotations];
    for (PKOAnnotation *ann in annotations) {
        if ([ann.contact.name isEqualToString:contact.name]) {
            targetAnn = ann;
            break;
        }
    }
    
    if (targetAnn) {
        [_mapView selectAnnotation:targetAnn animated:YES];
    } else {
        [self showContactActionMenuWithContact:contact];
    }
}

- (void) didReceiveContacts:(NSArray *)contacts
{
    //NSMutableArray *annotationsForReuse = [[NSMutableArray alloc] init];
    //NSMutableArray *newAnnotations = [[NSMutableArray alloc] init];
    
    // Wanted to reuse annotations but it seems like a lot of work to figure out
    // if anything has changed - just create new ones for now
    for (PKOAnnotation *annotation in _mapView.annotations) {
        if (!annotation.isUser) {
            [_mapView removeAnnotation:annotation];
        }
    }
    
    for (PKOContact * contact in contacts) {
        if (!contact.lat || contact.lat == 0 || !contact.lon || contact.lon == 0) {
            continue;
        }
        
        CLLocationCoordinate2D contactLocation;
        contactLocation.latitude = contact.lat;
        contactLocation.longitude= contact.lon;
        PKOAnnotation *ann = [[PKOAnnotation alloc] initWithName:contact.first_name
                                                   andCoordinate:contactLocation];
        ann.contact = contact;
        [_mapView addAnnotation:ann];
    }
    
    [self updateOutOfRangeList];
}

#pragma mark- PKORequestManagerDelegate Protocol

- (void) requestDidReceiveForbidden
{
    [commonTabController requestDidReceiveForbidden];
}

- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
    // Not sure why this would ever happen
}


- (void) requestDidReceiveNotFound
{
    // TODO: Fix the backend so it does not return 404 when msg not yet created
    [self hideButtons];
    [statusMessageController showViewWithNewText:@"My Message..."];
}

- (void) didReceiveMyAccountInfo:(NSDictionary *)info
{
    user.info.first_name = [info objectForKey:@"first_name"];
    user.info.last_name  = [info objectForKey:@"last_name"];
    user.info.phone      = [info objectForKey:@"phone"];
    user.password        = [info objectForKey:@"enc_password"];
}

- (void) didReceiveMyStatus:(NSDictionary *)status
{
    
    NSString *msg = [status objectForKey:@"msg"];
    
    // Update the shared user to have the right message and status/mood
    [user setStatusMsg:msg];
    [user setMood:[status objectForKey:@"status"]];
    [user.upforActivities removeAllObjects];

    NSArray *activities = [status objectForKey:@"up_for"];
    
    for (NSString *activity in activities) {
        [user.upforActivities setObject:@"selected" forKey:activity];
    }
    
    if (shouldShowStatus) {
        [self hideButtons];
        [statusMessageController showViewWithNewText:msg];
        shouldShowStatus = NO;
    }
    
    // Update the user's location after the status is received to make sure their
    // dot color is accurate
    [self updateLocation];
}

@end
