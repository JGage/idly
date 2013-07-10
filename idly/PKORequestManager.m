//
//  PKORequestManager.m
//
//  Created by Brandon Eum on 2/17/13.
//

#import "PKORequestManager.h"
#import "PKOHTTPRequest.h"
#import "PKOFormDataRequest.h"

@implementation PKORequestManager

@synthesize user, delegate, scheme, server;

#pragma mark- Initialization Methods

- (id) init
{
    self = [super init];
    
    // Set some basic values for the method and server
    // TODO: Is there a better place to store these?
    if (self) {
        scheme = @"http://";
        server = @"smartiparti.com/";
        //server = @"10.99.1.114:8080/";
        //server = @"localhost:8080/";
        user   = [PKOUserContainer sharedContainer];
    }
    
    return self;
}

#pragma mark- Shared Methods

// TODO: Change to AF Networking

// All of the get requests have a similar format, compact into this helper
- (void) initiateRequestWithFormat:(NSString *)urlFormat
                         withRoute:(Routes)route
                          withData:(NSData *)data
                        withMethod:(NSString *)method
{
    NSString *urlStr;
    
    if (route == CreateAccount || route == UpdatePassword) {
        urlStr = [NSString stringWithFormat: urlFormat, scheme, server];
    } else {
        urlStr = [NSString stringWithFormat: urlFormat, scheme, server, user.apikey];
    }
    
    //NSLog(@"PKORM: Request with URL: %@", urlStr);
    
    // Create the URL with the given format string
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // Create a new request and begin the request
    PKOHTTPRequest *request = [PKOHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRoute:route];
    [request setRequestMethod:method];
    
    if (data) {
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request appendPostData:data];
    }
    
    [request startAsynchronous];
}

- (void) initiateFormDataRequestWithFormat:(NSString *)urlFormat withRoute:(Routes)route withData:(NSData *)data
{
    NSString *urlStr = [NSString stringWithFormat: urlFormat, scheme, server, user.apikey];
    
    //NSLog(@"PKORM: Request with URL: %@", urlStr);
    
    // Create the URL with the given format string
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // Create a new request and begin the request
    PKOFormDataRequest *request = [PKOFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRoute:route];
    
    // Modifications for specific routes
    if (route == UploadProfileImage) {
        [request setData:data withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"image"];
    }
    
    [request startAsynchronous];
}

#pragma mark- Get Images

- (UIImage *) getImageForSelf
{
    NSString *format = @"%@%@account/photo/?api_key=%@";
    NSString *urlStr = [NSString stringWithFormat:format, scheme, server, user.apikey];
    
    NSLog(@"URL: %@", urlStr);
    
    NSURL *url       = [NSURL URLWithString: urlStr];
    UIImage *photo   = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    return photo;
}

- (UIImage *) getImageForUser:(NSString *)username
{
    NSString *format = @"%@%@contacts/%@/photo/?api_key=%@";
    NSString *urlStr = [NSString stringWithFormat:format, scheme, server, username, user.apikey];
    
    NSURL *url       = [NSURL URLWithString: urlStr];
    UIImage *photo   = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    return photo;
}


#pragma mark- Create Account and Login

- (void) createAccountWithData:(NSDictionary *)userData
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization
        dataWithJSONObject:userData
        options:0
        error:&error
    ];
    
    [self
        initiateRequestWithFormat:@"%@%@account/"
        withRoute:CreateAccount
         withData:jsonData
       withMethod:@"PUT"
    ];
}


- (void) loginWithUsername:(NSString *)name withPassword:(NSString *)password
{
    NSMutableDictionary *body = [NSMutableDictionary new];
    [body setObject:name forKey:@"user_name"];
    [body setObject:password forKey:@"enc_password"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                       options:0
                                                         error:&error];
    [self initiateRequestWithFormat:@"%@%@account/private/regenerate-api-key/"
                          withRoute:Login
                           withData:jsonData
                         withMethod:@"POST"
     ];
}

// Create contact objects for each of the prospective contacts
- (void) createProspectContacts:(NSArray *)prospects
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:prospects
                                                       options:0
                                                         error:&error];
    
    [self initiateRequestWithFormat:@"%@%@contacts/multiple/prospects/?api_key=%@"
                          withRoute:CreateProspectContacts
                           withData:jsonData
                         withMethod:@"POST"
     ];
}

#pragma mark- Update Account Info

- (void) updateAccount:(NSDictionary *)userData
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userData
                                                       options:0
                                                         error:&error
                        ];
    
    [self initiateRequestWithFormat:@"%@%@account/?api_key=%@"
                          withRoute:UpdateAccount
                           withData:jsonData
                         withMethod:@"POST"
     ];
}

- (void) updatePasswordWithUsername:(NSString *)username
                        andPassword:(NSString *)pass
                     andNewPassword:(NSString *)newPass
{
    NSMutableDictionary *passwordUpdate = [NSMutableDictionary new];
    [passwordUpdate setObject:username forKey:@"user_name"];
    [passwordUpdate setObject:pass forKey:@"enc_password"];
    [passwordUpdate setObject:newPass forKey:@"new_password"];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:passwordUpdate
                                                       options:0
                                                         error:&error
                        ];
    
    [self initiateRequestWithFormat:@"%@%@account/private/update-password/"
                          withRoute:UpdatePassword
                           withData:jsonData
                         withMethod:@"POST"
     ];
}

#pragma mark- Update methods

- (void) uploadProfileImage:(NSData *)image
{
    [self initiateFormDataRequestWithFormat:@"%@%@account/photo/?api_key=%@"
        withRoute:UploadProfileImage
        withData:image
    ];
}


- (void) updateLocationWithLatitude:(double)lat withLongitude:(double)lon
{
    NSString *postJsonString = [NSString stringWithFormat:@"{\"loc\":[%f,%f]}", lon, lat];
    NSData *data = [postJsonString dataUsingEncoding:NSUTF8StringEncoding];
    [self initiateRequestWithFormat:@"%@%@locations/account/?api_key=%@"
                          withRoute:UpdateLocation
                           withData:data
                         withMethod:@"POST"
    ];
}

- (void) upsertMultipleContacts:(NSString *)postJsonString
{
    NSData *data = [postJsonString dataUsingEncoding:NSUTF8StringEncoding];
    [self initiateRequestWithFormat:@"%@%@contacts/multiple/?api_key=%@"
                          withRoute:UpsertMultipleContacts
                           withData:data
                         withMethod:@"POST"
    ];
}

- (void) updateStatus:(NSData *)data
{
    [self initiateRequestWithFormat:@"%@%@account/status/?api_key=%@"
                          withRoute:UpdateStatus
                           withData:data
                         withMethod:@"POST"
    ];
}

- (void) addActivity:(NSString *)activity
{
    NSMutableString *url = [[NSMutableString alloc] initWithFormat:@"%%@%%@account/status/up-for/%@?api_key=%%@", activity];
    [self initiateRequestWithFormat:url
                          withRoute:AddActivity
                           withData:nil
                         withMethod:@"PUT"
     ];
}

- (void) removeActivity:(NSString *)activity
{
    NSMutableString *url = [[NSMutableString alloc] initWithFormat:@"%%@%%@account/status/up-for/%@?api_key=%%@", activity];
    [self initiateRequestWithFormat:url
                          withRoute:RemoveActivity
                           withData:nil
                         withMethod:@"DELETE"
     ];
}

- (void) updateContact:(NSString *)username
      withRelationship:(NSString *)rs
           withDisplay:(NSString *)ds
{
    NSString *json;
    if (rs && ds) {
        json = [NSString stringWithFormat:@"{\"activation\":{\"status\":\"%@\"},\"display\":{\"status\":\"%@\"}}", rs, ds];
    } else if (rs && !ds) {
        json = [NSString stringWithFormat:@"{\"activation\":{\"status\":\"%@\"}}", rs];
    } else {
        json = [NSString stringWithFormat:@"{\"display\":{\"status\":\"%@\"}}", ds];
    }
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    [self initiateRequestWithFormat:[NSString stringWithFormat:@"%%@%%@contacts/%@/?api_key=%%@", username]
                          withRoute:UpdateContact
                           withData:data
                         withMethod:@"POST"
     ];
}

- (void) updateAllContactsWithDisplayStatus:(NSString *)status
{
    NSMutableString *url = [[NSMutableString alloc] initWithFormat:@"%%@%%@contacts/display/status/update/%@?api_key=%%@", status];
    [self initiateRequestWithFormat:url
                          withRoute:UpdateAllContacts
                           withData:nil
                         withMethod:@"POST"
     ];
}

#pragma mark- Methods to Get Information

// Get pending sync requests
- (void) initiateMyAccountInfoRetrieval
{
    [self initiateRequestWithFormat:@"%@%@account/?api_key=%@"
                          withRoute:GetMyAccountInfo
                           withData:nil
                         withMethod:@"GET"
     ];
}

- (void) searchForContacts:(NSArray *)info
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    [self initiateRequestWithFormat:@"%@%@users/search/?api_key=%@"
                          withRoute:SearchForContacts
                           withData:data
                         withMethod:@"POST"
     ];
}


// Get pending sync requests
- (void) initiateSyncRequestRetrieval
{
    [self initiateRequestWithFormat:@"%@%@contacts/pending/names/?api_key=%@"
                          withRoute:GetSyncRequests
                           withData:nil
                         withMethod:@"GET"
    ];
}

- (void) initiateActiveContactsRetrieval
{
    [self initiateRequestWithFormat:@"%@%@contacts/accepted/account-info/?api_key=%@"
                          withRoute:GetActiveContacts
                           withData:nil
                         withMethod:@"GET"
    ];
}

- (void) initiateMyStatusRetrieval
{
    [self initiateRequestWithFormat:@"%@%@account/status/?api_key=%@"
                          withRoute:GetMyStatus
                           withData:nil
                         withMethod:@"GET"
    ];
}

- (void) initiateContactLocationRetrieval
{
    [self initiateRequestWithFormat:@"%@%@locations/contacts/?api_key=%@"
                          withRoute:GetContactLocations
                           withData:nil
                         withMethod:@"GET"
    ];
}

- (void) initiateContactStatusRetrieval
{
    [self initiateRequestWithFormat:@"%@%@contacts/active/status/?api_key=%@"
                          withRoute:GetContactStatuses
                           withData:nil
                         withMethod:@"GET"
    ];
}

- (void) initiateAllContactInfoRetrieval
{
    [self initiateRequestWithFormat:@"%@%@contacts/active/all-info/?api_key=%@"
                          withRoute:GetAllContactInfo
                           withData:nil
                         withMethod:@"GET"
     ];
}


#pragma mark- ASIHTTPRequestDelegate Protocol Methods

// TODO: Replace with AFNetworking - Supports ARC
- (void) requestFinished:(PKOHTTPRequest *)request
{
    //NSLog(@"PKORM: Response string: %@", [request responseString]);
    
    if ([request responseStatusCode] == 403) {
        NSLog(@"PKORM: Received 403 response");
        [delegate requestDidReceiveForbidden];
        return;
    }
    
    if ([request responseStatusCode] == 404 && [delegate respondsToSelector:@selector(requestDidReceiveNotFound)]) {
        NSLog(@"PKORM: Received 404 response");
        [delegate requestDidReceiveNotFound];
        return;
    } else if ([request responseStatusCode] == 404) {
        return;
    }
    
    NSString     *responseString = [request responseString];
    NSData       *responseData   = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError      *error          = nil;
    NSDictionary *jsonResponse   = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    
    if ([request responseStatusCode] == 400) {
        NSLog(@"PKORM: Received 400 response");
        [delegate requestDidReceiveBadRequest:jsonResponse];
        return;
    }
    
    // Call the appropriate delegate methods
    
    // Create Routes
    if ([request route] == CreateAccount && [delegate respondsToSelector:@selector(didCreateAccount:)]) {
        [delegate didCreateAccount:jsonResponse];
    
    } else if ([request route] == Login && [delegate respondsToSelector:@selector(didLogin:)]) {
        [delegate didLogin:jsonResponse];
    }
    
    // Update Routes
    if ([request route] == UpsertMultipleContacts && [delegate respondsToSelector:@selector(didUpdateContacts:)]) {
        [delegate didUpdateContacts:jsonResponse];
        
    } else if ([request route] == UpdateLocation && [delegate respondsToSelector:@selector(didUpdateLocation:)]) {
        [delegate didUpdateLocation:jsonResponse];
        
    } else if (([request route] == UpdateStatus || [request route] == AddActivity || [request route] == RemoveActivity) &&
               [delegate respondsToSelector:@selector(didUpdateStatus:)]) {
        [delegate didUpdateStatus:jsonResponse];
        
    } else if ([request route] == UpdateContact && [delegate respondsToSelector:@selector(didUpdateContact:)]) {
        [delegate didUpdateContact:jsonResponse];
        
    } else if ([request route] == UpdateAccount && [delegate respondsToSelector:@selector(didUpdateAccount:)]) {
        [delegate didUpdateAccount:jsonResponse];
        
    } else if ([request route] == UpdatePassword && [delegate respondsToSelector:@selector(didUpdatePassword:)]) {
        [delegate didUpdatePassword:jsonResponse];
    }

    // Get Routes
    if ([request route] == GetMyAccountInfo && [delegate respondsToSelector:@selector(didReceiveMyAccountInfo:)]) {
        [delegate didReceiveMyAccountInfo:jsonResponse];
        
    } else if ([request route] == SearchForContacts && [delegate respondsToSelector:@selector(didReceiveSearchResults:)]) {
        [delegate didReceiveSearchResults:jsonResponse];
        
    } else if ([request route] == GetSyncRequests && [delegate respondsToSelector:@selector(didReceiveSyncRequests:)]) {
        [delegate didReceiveSyncRequests:jsonResponse];
        
    } else if (([request route] == GetActiveContacts || [request route] == UpdateAllContacts) && [delegate respondsToSelector:@selector(didReceiveActiveContacts:)]) {
        [delegate didReceiveActiveContacts:jsonResponse];
    
    } else if ([request route] == GetMyStatus && [delegate respondsToSelector:@selector(didReceiveMyStatus:)]){
        [delegate didReceiveMyStatus:jsonResponse];
        
    } else if ([request route] == GetContactLocations && [delegate respondsToSelector:@selector(didReceiveContactLocations:)]){
        [delegate didReceiveContactLocations:jsonResponse];
        
    } else if ([request route] == GetContactStatuses && [delegate respondsToSelector:@selector(didReceiveContactStatuses:)]){
        [delegate didReceiveContactStatuses:jsonResponse];
        
    } else if ([request route] == GetAllContactInfo && [delegate respondsToSelector:@selector(didReceiveAllContactInfo:)]){
        [delegate didReceiveAllContactInfo:jsonResponse];
    }
    
    // Photo upload route
    if ([request route] == UploadProfileImage && [delegate respondsToSelector:@selector(didUpdateProfileImage)]) {
        [delegate didUpdateProfileImage];
    }
}

- (void)requestFailed:(PKOHTTPRequest *)request
{
    NSLog(@"PKORM: Request Failed");
    NSError *error = [request error];
    NSLog(@"%@", error);
}


@end
