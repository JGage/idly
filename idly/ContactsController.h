//
//  ContactsController.h
//  NewWorld
//
//  Created by Divakar Srinivasan on 10/12/12.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

#import "PKORequestManager.h"
#import "PKOUserContainer.h"
#import "PKOContact.h"

#import "ContactsTableController.h"

@protocol ContactsControllerDelegate <NSObject>

- (void) didDismissContactsView;
- (void) didReceiveContacts:(NSArray *)contacts;
- (void) didSelectContact:(PKOContact *)contact;
- (void) showAddressBook:(NSArray *)activeContacts;

@end

@interface ContactsController : UIViewController
<
    MultiContactsDelegate,
    MFMessageComposeViewControllerDelegate,
    UINavigationControllerDelegate,
    PKORequestManagerDelegate,
    ContactsTableControllerDelegate
>
{
    BOOL shown;
    
    __weak id delegate;
    
    CGRect initial;
    NSUserDefaults *prefs;
    BOOL checkmark,visibilityChanged;
    NSString *reqData;
    
    NSMutableArray *newUsersList, *prospectiveContacts;
    NSMutableArray *activeContacts;
    NSMutableDictionary *activeContactMap, *selectedContacts, *selectedContactMap;
    
    ContactsTableController *tableController;
    PKORequestManager *requestManager;
    PKOUserContainer *user;
    
    __weak IBOutlet UIImageView *statusImage;
    __weak IBOutlet UIActivityIndicatorView *loadingSymbol;
    
    BOOL isSelectAll;
    float originalHeight;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, readonly, strong) ContactsTableController *tableController;
@property (nonatomic, assign) IBOutlet UIButton *syncButton, *editButton, *selectAllButton;
@property (nonatomic, assign) IBOutlet UILabel *label;

- (IBAction) mapClicked:(id)sender;
- (IBAction) addContactsClicked:(id)sender;
- (IBAction) selectAllContacts:(id)sender;

- (void) showView;
- (void) dismissView;
- (IBAction) edit:(id)sender;
- (void) triggerSMSViewAlert;
- (void) sendSmsToNonappUsers;

- (void) getActiveContacts;


@end
