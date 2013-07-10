//
//  PlaceController.h
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "PKORequestManager.h"
#import "PKOUserContainer.h"
#import "PKOAnnotation.h"

#import "CustomAnnotationView.h"

#import "StatusMessageController.h"
#import "UpForController.h"
#import "ContactsController.h"
#import "PendingRequestAlertController.h"
#import "MoodController.h"
#import "OutOfRangeMaskController.h"
#import "OutOfRangeTableController.h"
#import "ContactActionMenuController.h"
#import "SettingsController.h"


#define METERS_PER_MILE 1609.344

@interface PlaceController : UIViewController
<
    UINavigationControllerDelegate,
    MFMessageComposeViewControllerDelegate,
    CLLocationManagerDelegate,
    MKMapViewDelegate,
    StatusMessageControllerDelegate,
    ContactsControllerDelegate,
    PKORequestManagerDelegate,
    MoodControllerDelegate
>
{
    PKORequestManager *requestManager;
    
    // Location related
    CLLocationManager *locationManager;
    PKOUserContainer *user;
    
    // Map View
    __weak IBOutlet MKMapView *_mapView;
    
    // Maintain a weak reference to the main view controller to send it messages
    __weak UIViewController<PKORequestManagerDelegate> *commonTabController;
    
    // View Outlets
    __weak IBOutlet UIButton *msgButton;
    __weak IBOutlet UIButton *settingsButton;
    __weak IBOutlet UIButton *contactsButton;
    __weak IBOutlet UIButton *outOfRangeCountButton;
    __weak IBOutlet UILabel  *outOfRangeCount;
    
    // Subviews
    StatusMessageController *statusMessageController;
    UpForController *upForController;
    ContactsController *contactsController;
    PendingRequestAlertController *pendingAlertController;
    MoodController *moodController;
    OutOfRangeMaskController *outOfRangeMaskController;
    OutOfRangeTableController *outOfRangeTableController;
    
    ContactActionMenuController *contactActionMenuController;
    PKOContact *actionMenuSubject;
    
    SettingsController *settingsController;
    
    // The annotation for the user
    PKOAnnotation *userAnnotation;
    PKOAnnotation *selectedAnnotation;
    
    // Keep track of the annotations in the map - Only for contacts
    NSMutableArray *allAnnotations;
    
    // BOOL flags for helping to control the view
    BOOL isFirstLocationUpdate;
    BOOL shouldShowStatus;
    BOOL isOutOfRangeMaskVisible;
    BOOL isOutOfRangeTableVisible;
    BOOL isUserOutOfRange;
}

@property (nonatomic, strong) ContactsController *contactsController;
@property (nonatomic, weak) UIViewController *commonTabController;

// UI interactions
- (IBAction) messageButtonClicked:(id)sender;
- (IBAction) settingsButtonClicked:(id)sender;
- (IBAction) contactsButtonClicked:(id)sender;
- (IBAction) outOfRangeCountButtonClicked:(id)sender;

- (void) showMoodController;
- (void) hideMoodController;

- (void) hideButtons;
- (void) showButtons;

- (void) didDismissStatusMessageView;
- (void) didDismissContactsView;

- (void) showSyncRequestWithName:(NSString *)name andImage:(UIImage *)img andUsername:(NSString *)username;

- (void) showContactActionMenuWithContact: (PKOContact *) contact;

// Map view communication methods
- (void) recenterMapWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude;
- (void) updateOutOfRangeList;
- (void) updateLocation;
- (void) refreshAnnotations;


@end