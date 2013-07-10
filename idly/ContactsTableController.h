//
//  ContactsTableController.h
//
//  Created by Brandon Eum on 2/26/13.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "PKOContact.h"
#import "PKORequestManager.h"
#import "MultiContacts.h"
#import "ContactTableCellView.h"

@protocol ContactsTableControllerDelegate <NSObject>

- (void) didSelectContact:(PKOContact *)contact;

@optional

- (void) didUpdateContactStatus;

@end

@interface ContactsTableController : UITableViewController
<
    UITableViewDelegate,
    UITableViewDataSource,
    PKORequestManagerDelegate
>
{
    id<ContactsTableControllerDelegate> delegate;

    NSArray *arrayLetters;
    NSMutableDictionary *selectedContacts;
    NSMutableDictionary *alphabetwiseDictionary;
    NSMutableArray *newUsersList;

    PKORequestManager *requestManager;
    NSMutableArray *activeContacts;
    
    float height, width, yorigin;
    BOOL shouldHideAccessory;
}

@property (nonatomic, strong) id<ContactsTableControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *activationQueueContacts;
@property (nonatomic, strong) NSMutableArray *filteredListContent, *activeContacts;
@property (nonatomic, assign) float height, width;
@property (nonatomic, assign) BOOL shouldHideAccessory;

- (void) checkButtonTapped:(id)sender event:(id)event;

- (void) addContact:(PKOContact *)contact;
- (void) updateContact: (NSString *)username;
- (void) removeAllContacts;

- (void) groupContactsForSection;

@end
