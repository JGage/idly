//
//  PKORequestManager.h
//
//  Manages all outgoing HTTP requests for this application
//  Encapsulates routes and request logic and error handling
//
//  TODO: Instead of using NSDictionary, use objects
//
//  Created by Brandon Eum on 2/17/13.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "PKOUserContainer.h"

typedef enum Routes {
    SearchForContacts      = 0,
    GetSyncRequests        = 1,
    GetActiveContacts      = 2,
    GetMyStatus            = 3,
    GetContactLocations    = 4,
    GetContactStatuses     = 5,
    GetAllContactInfo      = 6,
    
    Login                  = 7,
    CreateAccount          = 8,
    
    UpdateLocation         = 9,
    UploadProfileImage     = 10,
    UpsertMultipleContacts = 11,
    UpdateStatus           = 12,
    
    AddActivity            = 13,
    RemoveActivity         = 14,
    UpdateContact          = 15,
    UpdateAllContacts      = 16,
    UpdateAccount          = 17,
    UpdatePassword         = 18,
    CreateProspectContacts = 19,
    GetMyAccountInfo       = 20
} Routes;

@protocol PKORequestManagerDelegate;
@interface PKORequestManager: NSObject <ASIHTTPRequestDelegate>
{
    // Shared user container containing the User Information
    PKOUserContainer *user;
    
    // Delegate for handling requests
    __weak id <PKORequestManagerDelegate> delegate;
    
    // http or https
    NSString *scheme;
    
    // Remote server that manages the app's REST api
    NSString *server;
}

@property (nonatomic, strong) PKOUserContainer *user;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *server;

// Helper methods
- (void) initiateRequestWithFormat:(NSString *)urlFormat
                         withRoute:(Routes)route
                          withData:(NSData *)data
                        withMethod:(NSString *)method;

- (void) initiateFormDataRequestWithFormat:(NSString *)urlFormat withRoute:(Routes)route withData:(NSData *)data;

// Make an image request
- (UIImage *) getImageForSelf;
- (UIImage *) getImageForUser:(NSString *)username;

// Account creation and management
- (void) createAccountWithData:(NSDictionary *)userData;
- (void) loginWithUsername:(NSString *)name withPassword:(NSString *)password;
- (void) createProspectContacts:(NSArray *) prospects;

// Update name and password
- (void) updateAccount:(NSDictionary *)userData;
- (void) updatePasswordWithUsername:(NSString *)username
                        andPassword:(NSString *)pass
                     andNewPassword:(NSString *)newPass;

// Update with info from the phone
- (void) updateLocationWithLatitude:(double)lat withLongitude:(double)lon;
- (void) uploadProfileImage:(NSData *) image;

- (void) updateStatus:(NSData *)data;
- (void) addActivity:(NSString *)activity;
- (void) removeActivity:(NSString *)activity;

- (void) upsertMultipleContacts:(NSString *)postJsonString;
- (void) updateContact:(NSString *)username withRelationship:(NSString *)rs withDisplay:(NSString *)ds;
- (void) updateAllContactsWithDisplayStatus:(NSString *)status;

// Retrieve information from the server
- (void) initiateMyAccountInfoRetrieval;
- (void) searchForContacts:(NSArray *)info;

- (void) initiateSyncRequestRetrieval;
- (void) initiateActiveContactsRetrieval;
- (void) initiateMyStatusRetrieval;
- (void) initiateContactLocationRetrieval;
- (void) initiateContactStatusRetrieval;
- (void) initiateAllContactInfoRetrieval;

@end

// Protocol for the request manager's delegate
// TODO: Use block callbacks rather than delegate methods for a cleaner implementation
@protocol PKORequestManagerDelegate <NSObject>

- (void) requestDidReceiveForbidden;
- (void) requestDidReceiveBadRequest: (NSDictionary *)response;

@optional

- (void) requestDidReceiveNotFound;

// Create
- (void) didCreateAccount:(NSDictionary *) userInfo;
- (void) didLogin:(NSDictionary *) userInfo;
- (void) didCreateProspectContacts:  (NSDictionary *) contacts;

// Update
- (void) didUpdateAccount:  (NSDictionary *) account;
- (void) didUpdatePassword: (NSDictionary *) account;
- (void) didUpdateLocation: (NSDictionary *) location;
- (void) didUpdateContacts: (NSDictionary *) updatedContacts;
- (void) didUpdateStatus:   (NSDictionary *) status;
- (void) didUpdateContact:  (NSDictionary *) contact;
- (void) didUpdateProfileImage;

// Retrieve
- (void) didReceiveMyAccountInfo:    (NSDictionary *) info;
- (void) didReceiveSearchResults:    (NSDictionary *) results;
- (void) didReceiveSyncRequests:     (NSDictionary *) requests;
- (void) didReceiveActiveContacts:   (NSDictionary *) contacts;
- (void) didReceiveMyStatus:         (NSDictionary *) status;
- (void) didReceiveContactLocations: (NSDictionary *) locations;
- (void) didReceiveContactStatuses:  (NSDictionary *) statuses;
- (void) didReceiveAllContactInfo:   (NSDictionary *) contacts;

@end
