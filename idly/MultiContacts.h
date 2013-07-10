//
//  NewWorld
//
//  Created by Divakar Srinivasan on 10/12/12.
//


#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <malloc/malloc.h>

#import "NSString+Additions.h"
#import "UIAlertView+UITableView.h"
#import "PKOContact.h"


typedef enum 
{
    DATA_CONTACT_TELEPHONE = 0,
    DATA_CONTACT_EMAIL = 1,
    DATA_CONTACT_ID = 2
}DATA_CONTACT;

@protocol MultiContactsDelegate <NSObject>
@required

- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type;
- (void) didDismissAddressBook;

@end

@class OverlayViewController;

@interface MultiContacts : UIViewController
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchDisplayDelegate,
    UISearchBarDelegate,
    AlertTableViewDelegate
>
{
    
	id delegate;
	DATA_CONTACT requestData;
    NSArray *recordIDs;
    BOOL showModal, showCheckButton;

    
@private
    
    IBOutlet UITableView *table;
	IBOutlet UIBarButtonItem *cancelItem;
	IBOutlet UIBarButtonItem *doneItem;
	IBOutlet UISearchBar *barSearch;
    IBOutlet UISearchBar *searchBar;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UINavigationBar *upperBar;
    
    UITableView *currentTable;
    NSArray *data;
	NSMutableArray *arrayLetters;
	NSMutableArray *filteredListContent;
    NSMutableArray *dataArray;
	NSMutableArray *selectedRow;
    NSMutableDictionary *selectedItem;
    AlertTableView *alertTable;
    NSInteger savedScopeButtonIndex;
    NSString *alertTitle;
    NSMutableArray * tempArray;
    NSArray *matchingObjs;
    NSMutableArray * filteredListArray;
    NSMutableArray * duplicateRemovedArray;
    
    NSMutableDictionary *existingNumbers;
    
    BOOL isAccessDenied;
}

- (void) dismiss;
- (void) displayChanges:(BOOL)yesOrNO;
- (void) filterContacts;

- (void) setupContactView;

// Add contacts
- (void) addExistingContact:(PKOContact *)contact;


// Utilities
- (BOOL) startsWithLetter:(NSString *)str;
- (BOOL) isStringInArray:(NSString *) str withArray:(NSArray *)arr;
- (NSString *) reformatTelephoneFromString:(NSString *)number;
- (NSString *) customTelephoneFormatWithString:(NSString *)number;


@property (nonatomic, strong) NSMutableArray * activated;

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneItem;
@property (nonatomic, strong) IBOutlet UISearchBar *barSearch;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSMutableArray *arrayLetters;
@property (nonatomic, strong) NSMutableDictionary *selectedItem;
@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, strong) id<MultiContactsDelegate> delegate;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (nonatomic, strong) AlertTableView *alertTable;
@property (nonatomic, strong) UITableView *currentTable;
@property (nonatomic) DATA_CONTACT requestData;
@property (nonatomic, strong) NSString *alertTitle;
@property (nonatomic, strong) NSArray *recordIDs;
@property (nonatomic) BOOL showModal;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic) BOOL showCheckButton;
@property (nonatomic, strong) IBOutlet UINavigationBar *upperBar;

@end
