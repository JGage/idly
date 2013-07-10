//
//  ContactsController.m
//  NewWorld
//
//  Created by Divakar Srinivasan on 10/12/12.
//

#import "ContactsController.h"

@implementation ContactsController

@synthesize delegate, tableController, syncButton, editButton, selectAllButton, label;

#pragma mark- Init, dealloc, memory

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        user = [PKOUserContainer sharedContainer];
        requestManager  = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
        
        tableController  = [[ContactsTableController alloc] init];
        [tableController setDelegate:self];
        
        activeContacts     = [[NSMutableArray alloc] init];
        selectedContacts   = [[NSMutableDictionary alloc] init];
        selectedContactMap = [[NSMutableDictionary alloc] init];
        activeContactMap   = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getActiveContacts)
                                                     name:@"mastertimer"
                                                   object:nil
        ];
        
        isSelectAll = NO;
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- View Life Cycle

- (void) viewDidLoad
{
    if (!originalHeight) {
        originalHeight = self.view.frame.size.height;
    }
    NSLog(@"Original HEIGHT >>>>>> %f", originalHeight);
    
    [super viewDidLoad];
    statusImage.image = [UIImage imageNamed:@"on.png"];    
    
    // Set the position of the view and hide it
    float yOrigin = (self.view.superview.frame.size.height - originalHeight) + originalHeight;
    [self.view setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width, originalHeight)];
    [self.view addSubview:tableController.tableView];
}


- (void) viewWillDisappear:(BOOL)animated
{
    if (visibilityChanged) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"contactsVisibility" object:nil];
    }
    [super viewWillDisappear:animated];
}

#pragma mark- Show and Hide View

- (void) showView
{
    // Initiate contact retrieval
    [self getActiveContacts];
    
    // Show loading symbol
    [loadingSymbol startAnimating];
    
    // Animations

    float yOrigin = (self.view.superview.frame.size.height + originalHeight);
    [self.view setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width, originalHeight)];
    [self.view setHidden:NO];
    
    [UIView animateWithDuration:0.5
        animations:^{
            float yOrigin = (self.view.superview.frame.size.height - originalHeight);
            [self.view setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width, originalHeight)];
        }
        completion:^(BOOL finished) {}
    ];
}

- (void) dismissView
{
    [UIView animateWithDuration:0.5
        animations:^{
            float yOrigin = (self.view.superview.frame.size.height + self.view.frame.size.height);
            [self.view setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width, self.view.frame.size.height)];
        }
        completion:^(BOOL finished) {
            [self.view setHidden:YES];
            [delegate didDismissContactsView];
        }
     ];
}


// Resize the view once the address book is dismissed
- (void) didDismissAddressBook
{
    //float yOrigin = (self.view.superview.frame.size.height - originalHeight);
    //[self.view setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width, originalHeight)];
    [self.view setHidden:YES];
    [self dismissView];
}

#pragma mark- Table Delegate for address book

- (NSString *) reformatTelephoneFromString:(NSString *)number
{
    if ([number containsString:@"-"])
    {
        number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    if ([number containsString:@" "])
    {
        number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if ([number containsString:@"("])
    {
        number = [number stringByReplacingOccurrencesOfString:@"(" withString:@""];
    }
    
    if ([number containsString:@")"])
    {
        number = [number stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    
    return number;
}

// Getting phone number from user selected contacts after the address book
// view returns
- (void)numberOfRowsSelected:(NSInteger)numberRows
                    withData:(NSArray *)data
                 andDataType:(DATA_CONTACT)type
{
    // Reset the size of the view after it returns
    float yOrigin = (self.view.superview.frame.size.height - originalHeight);
    [self.view setFrame:CGRectMake(0, yOrigin, self.view.frame.size.width, originalHeight)];
    
    // If the data was not the correct type, return, in the future we may support
    // search by more than just telephone
    if (type != DATA_CONTACT_TELEPHONE) {
        return;
    }
    
    NSMutableArray *selectedUsersPhones = [[NSMutableArray alloc] init];
    [selectedContacts removeAllObjects];
    
    for (int i = 0; i < [data count]; i++) {
        NSDictionary *dict = [data objectAtIndex:i];
        NSString *str =[dict valueForKey:@"phoneNumber"];
        
        str = [self reformatTelephoneFromString:str];
        
        if (str.length < 10) {
            continue;
        }
        
        // Create the components of a telephone number
        str = [str substringFromIndex:str.length-10];
        NSString *unformatted = str;
        NSArray *stringComponents = [NSArray arrayWithObjects:
            [unformatted substringWithRange:NSMakeRange(0, 3)],
            [unformatted substringWithRange:NSMakeRange(3, 3)],
            [unformatted substringWithRange:NSMakeRange(6, [unformatted length]-6)],
            nil
        ];
        
        NSString *formattedString = [NSString stringWithFormat:@"%@-%@-%@",
                                     [stringComponents objectAtIndex:0],
                                     [stringComponents objectAtIndex:1],
                                     [stringComponents objectAtIndex:2]];
        
        [selectedContacts setObject:[dict valueForKey:@"username"] forKey:formattedString];
        [selectedContactMap setObject:dict forKey:formattedString];
        
        
        NSDictionary *entry = [[NSDictionary alloc]
            initWithObjects:[[NSArray alloc] initWithObjects:formattedString, nil]
                    forKeys:[[NSArray alloc] initWithObjects:@"phone", nil]
        ];
        
        [selectedUsersPhones addObject:entry];
    }
    
    if ([selectedUsersPhones count] > 0) {
        [requestManager searchForContacts:selectedUsersPhones];
    } else {
        // TODO: Fix
        //[UIAlertview_Addition alert:@"Please select a contact with a valid mobile number." withTitle:@"Error"];
    }
    
}


#pragma mark- UI Interactions

// Edit the contact list
- (IBAction) edit:(id)sender
{
    if (editButton.selected) {
        [editButton setSelected:NO];
        [tableController.tableView setEditing:NO animated:YES];
    } else {
        [editButton setSelected:YES];
        [tableController.tableView setEditing:YES animated:YES];
    }

}


// If a user clicks outside the contact region, the view should dismiss
- (IBAction) mapClicked:(id)sender
{
    [self dismissView];
}

- (IBAction) syncContactsClicked:(id)sender
{
    [self showContacts];
}

- (IBAction) selectAllContacts:(id)sender
{
    UIButton *selectAll = (UIButton *)sender;

    if (selectAll.selected) {
        [requestManager updateAllContactsWithDisplayStatus:@"exhibitionist"];
        [selectAll setSelected:NO];
        isSelectAll = NO;
    } else {
        [requestManager updateAllContactsWithDisplayStatus:@"visible"];
        [selectAll setSelected:YES];
        isSelectAll = YES;
    }
}

#pragma mark- Contacts Manipulation

// shows contacts from addressbook
- (void)showContacts
{
    // TODO: Make the MultiContacts controller its own delegate
    MultiContacts *controller = [[MultiContacts alloc] initWithNibName:@"MultiContacts" bundle:nil];
    controller.delegate = self;
    controller.requestData = DATA_CONTACT_TELEPHONE;
    controller.showModal = YES;
    controller.showCheckButton = YES;  

    for (PKOContact *contact in activeContacts) {
        [controller addExistingContact:contact];
    }
    [self presentViewController:controller animated:YES completion:^{}];
}

#pragma mark- Contact Table View Delegate

- (void) didSelectContact:(PKOContact *)contact
{
    [self dismissView];
    [self.delegate didSelectContact:contact];
    [self getActiveContacts];
}

- (void) didUpdateContactStatus
{
    [self getActiveContacts];
}


#pragma mark- SMS View Methods

// alert for non registered users
// This is triggered by the alert in didReceiveSearchResults
// An alert always displays
- (void) alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (alertView.tag) {
        case 1:
            if (newUsersList.count > 0) {
                [self triggerSMSViewAlert];
            }
            break;
        case 2:
            if (buttonIndex==0) {
                [self sendSmsToNonappUsers];
            }
            break;
        default:
            break;
    }
}

- (void) triggerSMSViewAlert
{
    UIAlertView *alert = [[UIAlertView alloc]
        initWithTitle:@"Add Friends"
        message:@"Would you like to send an invitation via SMS to your friends who don't use Idly?"
        delegate:self
        cancelButtonTitle:@"OK"
        otherButtonTitles:@"Cancel",nil
    ];
    alert.tag = 2;
    [alert show];
}

// sending sms for non app users
- (void) sendSmsToNonappUsers
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.delegate = self;
    if([MFMessageComposeViewController canSendText]) {
        controller.body = @"Join me on Idly!";
        controller.recipients = newUsersList ;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{}];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
	[self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark- Trigger web requests

// getActiveContacts method retrieves all synced contacts.  All synced/active contacts will be listed in ActivationQueue (ContactsController).
- (void) getActiveContacts
{
    [requestManager initiateAllContactInfoRetrieval];
}

#pragma mark- PKO Delegate Methods

- (void) requestDidReceiveNotFound{}
- (void) requestDidReceiveBadRequest:(NSDictionary *)response {}
- (void) requestDidReceiveForbidden
{
    // TODO: Call the places controller
}

// Result of hitting the select all button
// Mark all of the contacts as isVisible and reload the table
- (void) didReceiveActiveContacts:(NSDictionary *)contacts
{
    for (PKOContact *contact in tableController.activeContacts) {
        contact.isVisible = isSelectAll;
        contact.display_status = isSelectAll ? @"v" : @"e";
    }

    [tableController.tableView reloadData];
}

- (void) didReceiveAllContactInfo:(NSDictionary *)contacts
{
    // Stop the loading symbol
    [loadingSymbol stopAnimating];
    
    // Empty all of the contacts from the table controller and contact array
    [user.activeContacts removeAllObjects];
    [activeContactMap removeAllObjects];
    [activeContacts removeAllObjects];
    [tableController removeAllContacts];
    
    for (NSDictionary *contact in contacts) {
        PKOContact *mycontact = [[PKOContact alloc] init];
        
        NSString* userName = [contact objectForKey:@"user_name"];
        NSString* phone    = [contact objectForKey:@"phone"];
        NSString* fullName = [NSString stringWithFormat:@"%@ %@",
                              [contact objectForKey:@"first_name"],
                              [contact objectForKey:@"last_name"]
                              ];
        
        mycontact.name       = fullName;
        mycontact.first_name = [contact objectForKey:@"first_name"];
        mycontact.last_name  = [contact objectForKey:@"last_name"];
        mycontact.username   = userName;
        mycontact.phone      = phone;
        mycontact.type       = [contact objectForKey:@"type"];
        
        mycontact.activation_status = [contact objectForKey:@"activation_status"];
        mycontact.display_status = [contact objectForKey:@"display_status"];
        
        mycontact.isVisible  = false;
        mycontact.photo      = [requestManager getImageForUser:userName];
        
        NSDictionary *contact_location = [contact objectForKey:@"loc"];
        NSNumber *lat = (NSNumber *)[contact_location objectForKey:@"lat"];
        NSNumber *lon = (NSNumber *)[contact_location objectForKey:@"long"];
        
        mycontact.lat = [lat doubleValue];
        mycontact.lon = [lon doubleValue];
        
        mycontact.msg     = [contact objectForKey:@"msg"];
        mycontact.status  = [contact objectForKey:@"status"];
        
        // Set the up-for activities
        NSArray *upFor = [contact objectForKey:@"up_for"];
        [mycontact.upForActivities addObjectsFromArray:upFor];
        
        [tableController addContact:mycontact];
        [activeContactMap setObject:mycontact forKey:mycontact.username];
        [activeContacts addObject:mycontact];
        [user.activeContacts addObject:mycontact];
    }
    
    [delegate didReceiveContacts:activeContacts];
}

// Send sync requests to users based on the search results
- (void) didReceiveSearchResults:(NSDictionary *)results
{
    int currentAppUsers = 0;
    
    NSMutableString *selectedUsersJSONstr = [[NSMutableString alloc] initWithString:@"["];
    newUsersList        = [NSMutableArray new];
    prospectiveContacts = [NSMutableArray new];
    NSMutableArray *registeredUsers = [NSMutableArray new];
    
    
    // Loop through the search results and generate the contact list
    // TODO: Building the JSON string like this will fail if there is a double quote
    //       in the name
    for (NSDictionary* result in results) {
        if ([[result objectForKey:@"has_match"] boolValue]) {
            currentAppUsers++;
            [selectedUsersJSONstr appendFormat:@"{\"user_name\":\"%@\", \"activation\":{ \"status\":\"r\"}},",[[result objectForKey:@"match"] objectForKey:@"user_name"]];
            
            [registeredUsers addObject:[selectedContacts objectForKey:[[result objectForKey:@"original_contact"] objectForKey:@"phone"]]];
        } else {
            // Add the users who do not use pekko to an array of phone numbers and
            // to an array of dictionaries which will be used to create prospective
            // contacts
            NSString *phone = [[result objectForKey:@"original_contact"] objectForKey:@"phone"];
            [newUsersList addObject:phone];
            
            NSDictionary *orig_entry = [selectedContactMap objectForKey:phone];

            NSMutableDictionary *curr_prospect = [[NSMutableDictionary alloc] init];
            [curr_prospect setObject:phone forKey:@"phone"];
            [curr_prospect setObject:[orig_entry objectForKey:@"first_name"] forKey:@"first_name"];
            [curr_prospect setObject:[orig_entry objectForKey:@"last_name"] forKey:@"last_name"];
            [prospectiveContacts addObject:curr_prospect];
        }
    }
             
    // Make a request to create a relationship between the user and their
    // selected contacts.  The relationship will be "pending" until the target
    // of the reques accepts
    if (currentAppUsers > 0) {
        [selectedUsersJSONstr deleteCharactersInRange:NSMakeRange([selectedUsersJSONstr length]-1, 1)];
        [selectedUsersJSONstr appendString:@"]"];

        [requestManager upsertMultipleContacts:selectedUsersJSONstr];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invitations Sent Successfully to:"
                              message:[registeredUsers componentsJoinedByString:@",\n"]
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil
                              ];
        
        alert.tag = 1;
        [alert show];
    } else if ([newUsersList count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Sync Request"
                              message:@"No one was selected."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil
                              ];
        alert.tag = 4; // Set tag to not trigger other actions
        [alert show];
    } else {
        // Send the request to add contacts - we don't really care about the
        // response
        [requestManager createProspectContacts:prospectiveContacts];
        [self triggerSMSViewAlert];
    }
}

// Trigger a reload of contacts after sending sync requests
- (void) didUpdateContacts:(NSDictionary *)updatedContacts
{
    [self getActiveContacts];
}

@end
