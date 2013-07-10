//
//  NewWorld
//
//  Created by Divakar Srinivasan on 10/12/12.
//

#import "MultiContacts.h"


#pragma mark- NSString (BAD!)

@interface NSString (character)

- (BOOL)isRecordInArray:(NSArray *)array;

@end

@implementation NSString (character)

- (BOOL)isRecordInArray:(NSArray *)array
{
    for (NSString *str in array)
    {
        if ([self isEqualToString:str]) 
        {
            return YES;
        }
    }
    
    return NO;
}

@end


#pragma mark- NSMutable Array (BAD!)

@interface NSMutableArray (Duplicates)

- (NSMutableArray *)removeDuplicateObjects;

- (NSMutableArray *)removeNullValues;

- (NSMutableArray *)reverse;

@end



@implementation NSMutableArray (Duplicates)

- (NSMutableArray *)reverse
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    
    for (id element in enumerator) 
    {
        [array addObject:element];
    }
    
    return array;
}

- (NSMutableArray *)removeNullValues
{
    NSMutableArray *removed = [[NSMutableArray alloc] initWithArray:self];
    int index = 0;
    
    for (NSDictionary *d in self)
    {
        if ([[d valueForKey:@"name"] containsString:@"null"])
        {
            [removed removeObjectAtIndex:index];
        }
        
        index++;
    }
    
    return removed;
}

- (NSMutableArray *)removeDuplicateObjects
{
    NSMutableArray *removed = [[NSMutableArray alloc] initWithArray:self];
    NSMutableArray *removedTemp = [[[NSMutableArray alloc] initWithArray:self] reverse];
    NSMutableArray *selfTemp = [[[NSMutableArray alloc] initWithArray:self] reverse];

    int index = [removed indexOfObject:[removed lastObject]];
    
    for (NSDictionary *d in selfTemp)
    {
        NSString *t = [NSString stringWithFormat:@"%@", [d valueForKey:@"name"]];
        NSString *str1 = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        int count = 0;
        for (NSDictionary *dict in removedTemp)
        {
            NSString *t = [NSString stringWithFormat:@"%@", [dict valueForKey:@"name"]];
            NSString *str2 = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ([str1 isEqualToString:str2])
            {
                count++;
                
                if (count > 1)
                {
                    [removed removeObjectAtIndex:index];
                    index = [removed indexOfObject:[removed lastObject]];
                    removedTemp = nil;
                    removedTemp = [removed reverse];
                    break;
                }
            }
        }

        index--;
    }
    return removed;
}

@end


@implementation MultiContacts

@synthesize delegate, table, cancelItem, doneItem,filteredListContent, savedSearchTerm,
    savedScopeButtonIndex, searchWasActive, data, barSearch, alertTable, selectedItem,
    currentTable, arrayLetters, requestData, alertTitle, recordIDs, showModal,
    toolBar, showCheckButton, upperBar, activated;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        activated = [NSMutableArray new];
        existingNumbers = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark- Utility


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

- (NSString *) customTelephoneFormatWithString:(NSString *)number
{
    
     NSArray *stringComponents = [NSArray arrayWithObjects:[number substringWithRange:NSMakeRange(0, 3)],
     [number substringWithRange:NSMakeRange(3, 3)],
     [number substringWithRange:NSMakeRange(6, [number length]-6)], nil];
     
     
     number = [NSString stringWithFormat:@"%@-%@-%@", [stringComponents objectAtIndex:0], [stringComponents objectAtIndex:1], [stringComponents objectAtIndex:2]];
     return number;
}

#pragma mark- View Lifecycle


// Create the table view with the address book
- (void)viewDidLoad
{    
	[super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    // TODO: Not sure why this exception is thrown?
    if ((requestData != DATA_CONTACT_TELEPHONE) && 
        (requestData != DATA_CONTACT_EMAIL) &&
        (requestData != DATA_CONTACT_ID))
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
        
        @throw ([NSException exceptionWithName:@"Undefined data request"
                                        reason:@"Define requestData variable (EMAIL or TELEPHONE)" 
                                      userInfo:nil]);
    }
    
	NSArray *letters = [[NSArray alloc]
        initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                        @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R",
                        @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil
    ];
    
    arrayLetters = [[NSMutableArray alloc] initWithArray:letters];
    [arrayLetters addObject:@"#"];

    cancelItem.title = @"Cancel";
    doneItem.title   = @"Add";
    alertTitle       = @"Select";
    
	cancelItem.action = @selector(dismiss);
	doneItem.action   = @selector(acceptAction);
	
    // TODO: What modal is this?
    if (!showModal) {
        toolBar.hidden = YES;
        CGRect rect = table.frame;
        rect.size.height += toolBar.frame.size.height;
        table.frame = rect;
        table.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    // Create the address book and check if the app has access
    CFErrorRef *error = NULL;
	  ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    isAccessDenied = NO;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            if (granted) {
                isAccessDenied = NO;
                [self setupContactView];
            } else {
                isAccessDenied = YES;
                return;
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self setupContactView];
    } else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        isAccessDenied = YES;
        return;
    }
}

- (void) setupContactView
{
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
	  CFIndex nPeople      = ABAddressBookGetPersonCount(addressBook);
    
	  dataArray = [NSMutableArray new];
	
	  for (int i = 0; i < nPeople; i++) {
        
        // Pull the person from the array
        ABRecordRef person       = CFArrayGetValueAtIndex(allPeople, i);
        ABMultiValueRef property = ABRecordCopyValue(person, (requestData == DATA_CONTACT_TELEPHONE) ? kABPersonPhoneProperty : kABPersonEmailProperty);
            
        NSArray *propertyArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(property);
        CFBridgingRelease(property);
            
        NSString *objs = @"";
        BOOL lotsItems = NO;
        for (int i = 0; i < [propertyArray count]; i++) {
          if ([objs length] == 0) {
            objs = [propertyArray objectAtIndex:i];
                    objs = [self reformatTelephoneFromString:objs];
                    
                    // Skip non-telephone items
                    if (objs.length < 10) {
                        continue;
                    }
                    
                    // Reformat the string
                    objs = [objs substringFromIndex:objs.length - 10];
                    objs = [self customTelephoneFormatWithString:objs];
                    
          } else {
                    // TODO: Not sure what the difference is
                    lotsItems = YES;
                    
            objs = [objs stringByAppendingString:[NSString stringWithFormat:@",%@", [propertyArray objectAtIndex:i]]];
                    objs = [self reformatTelephoneFromString:objs];
                    objs = [self customTelephoneFormatWithString:objs];
                    
          }
        }
          
        // Check if the telephone number exists, if it does then skip this person
        if ([existingNumbers objectForKey:objs]) {
            continue;
        }
          
        CFStringRef name;
        name = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        
        CFStringRef lastNameString;
        lastNameString = ABRecordCopyValue(person, kABPersonLastNameProperty);
          
        NSString *nameString = (__bridge NSString *)name;
        NSString *lastName = (__bridge NSString *)lastNameString;
        int currentID = (int)ABRecordGetRecordID(person);
        
        NSMutableDictionary *info = [NSMutableDictionary new];

        // Set the first name as an object property
        if (nameString) {
            [info setObject:nameString forKey:@"first_name"];
        } else {
            [info setObject:@"Unknown" forKey:@"first_name"];
        }
        
        
        if ((__bridge id)lastNameString != nil) {
            nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastName];
            [info setObject:lastName forKey:@"last_name"];
        } else {
            [info setObject:@"" forKey:@"last_name"];
        }

          
        [info setValue:[NSString stringWithFormat:@"%@", [[nameString stringByReplacingOccurrencesOfString:@" " withString:@""] substringToIndex:1]] forKey:@"letter"];
        [info setValue:[NSString stringWithFormat:@"%@", nameString] forKey:@"name"];
        [info setValue:@"-1" forKey:@"rowSelected"];
        
        if (([objs length] > 0) || ([[objs lowercaseString] rangeOfString:@"null"].location == NSNotFound)) {
            if (requestData == DATA_CONTACT_EMAIL) {
                [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"email"];
                
                if (!lotsItems)  {
                    [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"emailSelected"];
                } else {
                    [info setValue:@"" forKey:@"emailSelected"];
                }
            } else if (requestData == DATA_CONTACT_TELEPHONE) {
                [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"telephone"];
                
                if (!lotsItems)  {
                    [info setValue:[NSString stringWithFormat:@"%@", objs] forKey:@"telephoneSelected"];
                } else {
                    [info setValue:@"" forKey:@"telephoneSelected"];
                }
            } else if (requestData == DATA_CONTACT_ID)  {
                [info setValue:[NSString stringWithFormat:@"%d", currentID] forKey:@"recordID"];
                [info setValue:@"" forKey:@"recordIDSelected"];
            }
        }
        
        if ([recordIDs count] > 0)  {
            NSString *currId = [NSString stringWithFormat:@"%d", currentID];
            BOOL insert = [self isStringInArray:currId withArray:recordIDs];
            
            if (insert) {
                [dataArray addObject:info];
            }
        } else {
            [dataArray addObject:info];
        }
        
        
        if (name) CFRelease(name);
        if (lastNameString) CFRelease(lastNameString);
	}
    
	CFRelease(allPeople);
	CFRelease(addressBook);
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:dataArray];
    
    //temp = [temp removeDuplicateObjects];
    
    dataArray = nil;
    dataArray = [NSArray arrayWithArray:temp];
    
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	data = [dataArray sortedArrayUsingDescriptors:sortDescriptors];
    
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
	self.searchDisplayController.searchBar.showsCancelButton = NO;
	
	NSMutableDictionary	*info = [NSMutableDictionary new];
	for (int i = 0; i < [arrayLetters count]; i++)
	{
		NSMutableArray *array = [NSMutableArray new];
		
		for (NSDictionary *dict in data)
		{
			NSString *name = [dict valueForKey:@"name"];
			name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			if ([[[name substringToIndex:1] uppercaseString] isEqualToString:[arrayLetters objectAtIndex:i]])
			{
				[array addObject:dict];
			}
		}
		
		[info setValue:array forKey:[arrayLetters objectAtIndex:i]];
	}
	
	for (int i = 0; i < [arrayLetters count]; i++)
	{
		NSMutableArray *array = [NSMutableArray new];
		
		for (NSDictionary *dict in data)
		{
			NSString *name = [dict valueForKey:@"name"];
			name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			if ((![self startsWithLetter:name]) && (![name containsNullString]))
			{
				[array addObject:dict];
			}
		}
		
		[info setValue:array forKey:@"#"];
	}
    
	dataArray = [[NSMutableArray alloc] initWithObjects:info, nil];
    tempArray=[[NSMutableArray alloc]init];
    duplicateRemovedArray=[[NSMutableArray alloc]init];
    filteredListArray=[[NSMutableArray alloc]init];
    self.filteredListContent = [NSMutableArray arrayWithCapacity:[data count]];
    
    matchingObjs=[[NSArray alloc]init];
    [self filterContacts];
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
	selectedRow = [NSMutableArray new];
	table.editing = NO;
	[self.table reloadData];
}


// Alerts the user that the feature is disabled if their privacy settings
// block the app from accessing their contacts
- (void) viewDidAppear:(BOOL)animated
{
    if (isAccessDenied) {
        UIAlertView *a = [[UIAlertView alloc]
            initWithTitle:@"Contacts Access Restricted"
            message:@"Please enable this app in your Privacy Settings to sync contacts"
            delegate:self
            cancelButtonTitle:@"OK"
            otherButtonTitles: nil
        ];
        [a show];
    }
}

// Handles dimissal from privacy warning
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismiss];
}

// Dismiss the modal view
- (void)dismiss
{
    [delegate didDismissAddressBook];
	[self dismissViewControllerAnimated:YES completion:^{

    }];
}

#pragma mark- Existing contacts

- (void) addExistingContact:(PKOContact *)contact
{
    [activated addObject:contact];
    [existingNumbers setObject:[NSNumber numberWithBool:YES] forKey:contact.phone];
}


#pragma mark- Utility Methods

- (BOOL) startsWithLetter:(NSString *)str
{
    BOOL isLetter;
    if ([[NSCharacterSet letterCharacterSet] characterIsMember:[str characterAtIndex:0]]) {
        isLetter = YES;
    } else {
        isLetter = NO;
    }
    return isLetter;
}

- (BOOL) isStringInArray:(NSString *)str withArray:(NSArray *)arr
{
    for (NSString *curr in arr) {
        if ([str isEqualToString:curr]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark- Submit Method

- (void) acceptAction
{
	NSMutableArray *objects = [NSMutableArray new];
    NSMutableDictionary * dict;
    
	for (int i = 0; i < [arrayLetters count]; i++) {
		NSMutableArray *obj =Nil;
        if (activated.count==0) {
            obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];
            
        } else {
            obj = [[duplicateRemovedArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];
            
        }
        
        for (int x = 0; x < [obj count]; x++) {
			NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
			BOOL checked = [[item objectForKey:@"checked"] boolValue];
            
			if (checked) {
                NSString *str = @"";
                NSString *strName = @"";
                
				if (requestData == DATA_CONTACT_TELEPHONE)  {
                    str = [item valueForKey:@"telephoneSelected"];
                    strName = [item valueForKey:@"name"];
                    
                    
                    if ([str length] > 0)  {
                        dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:str forKey:@"phoneNumber"];
                        [dict setValue:strName forKey:@"username"];
                        [dict setObject:[item objectForKey:@"first_name"] forKey:@"first_name"];
                        [dict setObject:[item objectForKey:@"last_name"] forKey:@"last_name"];
                        [objects addObject:dict];
                    }
                }
			}
		}
	}
    
    if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)])
        [self.delegate numberOfRowsSelected:[objects count] withData:objects andDataType:requestData];
	[self dismiss];
}


#pragma mark- Other Methods

- (void) filterContacts
{
    tempArray=[data mutableCopy];
   
    for (int i=0; i<activated.count; i++) {
       NSPredicate* predicate = [NSPredicate predicateWithFormat:@"telephoneSelected=%@",[activated objectAtIndex:i]];
        matchingObjs = [tempArray filteredArrayUsingPredicate:predicate];
        [filteredListArray addObject:matchingObjs];
    }
    for (NSArray*arr in filteredListArray) {
        for (NSDictionary *dict in arr) {
            [tempArray removeObject:dict];
        }
    }
    NSMutableDictionary *info=[NSMutableDictionary new];
    
    for (int i = 0; i < [arrayLetters count]; i++)
	{
		NSMutableArray *array = [NSMutableArray new];
		
		for (NSDictionary *dict in tempArray)
		{
            [duplicateRemovedArray removeAllObjects];

			NSString *name = [dict valueForKey:@"name"];
			name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			if ([[[name substringToIndex:1] uppercaseString] isEqualToString:[arrayLetters objectAtIndex:i]])
			{
				[array addObject:dict];
			}
		}
		
		[info setValue:array forKey:[arrayLetters objectAtIndex:i]];
        [duplicateRemovedArray addObject:info];
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        
		[self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
		[self tableView:self.table accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.table deselectRowAtIndexPath:indexPath animated:YES];
	}	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCustomCellID = @"MyCellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	NSMutableDictionary *item = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
            item = (NSMutableDictionary *)[self.filteredListContent objectAtIndex:indexPath.row];
    } else {
        NSMutableArray *obj =nil;
        if (activated.count==0 ){
            obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:indexPath.section]];
           // item = (NSMutableDictionary *)[obj objectAtIndex:indexPath.row];

        } else {
            obj=[[duplicateRemovedArray objectAtIndex:0]valueForKey:[arrayLetters objectAtIndex:indexPath.section]];
        }
        item=(NSMutableDictionary *)[obj objectAtIndex:indexPath.row];

	}
    
	cell.textLabel.text = [item objectForKey:@"name"];
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
	[item setObject:cell forKey:@"cell"];
	
	BOOL checked = [[item objectForKey:@"checked"] boolValue];
	UIImage *image = (checked) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (!showCheckButton)
        button.hidden = YES;
    else
        button.hidden = NO;
    
	CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	button.frame = frame;
	
	if (tableView == self.searchDisplayController.searchResultsTableView) 
	{
		button.userInteractionEnabled = NO;
	}
	
	[button setBackgroundImage:image forState:UIControlStateNormal];
    
	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
	cell.backgroundColor = [UIColor clearColor];
	cell.accessoryView = button;
	
	return cell;
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.table];
	NSIndexPath *indexPath = [self.table indexPathForRowAtPoint: currentTouchPosition];
	
	if (indexPath != nil)
	{
		[self tableView: self.table accessoryButtonTappedForRowWithIndexPath: indexPath];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{	
	NSMutableDictionary *item = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		item = (NSMutableDictionary *)[filteredListContent objectAtIndex:indexPath.row];
	} else {
        NSMutableArray *obj =nil;
        obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:indexPath.section]];
        item = (NSMutableDictionary *)[obj objectAtIndex:indexPath.row];
    }
    
    NSArray *objectsArray = nil;
    
    if (requestData == DATA_CONTACT_TELEPHONE)
        objectsArray = (NSArray *)[[item valueForKey:@"telephone"] componentsSeparatedByString:@","];
    else if (requestData == DATA_CONTACT_EMAIL)
        objectsArray = (NSArray *)[[item valueForKey:@"email"] componentsSeparatedByString:@","];
    else
        objectsArray = (NSArray *)[[item valueForKey:@"recordID"] componentsSeparatedByString:@","];
    
    int objectsCount = [objectsArray count];
    
    if (objectsCount > 1) {
        selectedItem = item;
        self.currentTable = tableView;
        
        alertTable = [[AlertTableView alloc] initWithCaller:self 
                                                       data:objectsArray 
                                                      title:alertTitle
                                                    context:self
                                                 dictionary:item
                                                    section:indexPath.section
                                                        row:indexPath.row];
        alertTable.isModal = showModal;
        [alertTable show];
    } else {
        
        if (showModal)  {
            BOOL checked = [[item objectForKey:@"checked"] boolValue];
            
            [item setObject:[NSNumber numberWithBool:!checked] forKey:@"checked"];
            
            UITableViewCell *cell = [item objectForKey:@"cell"];
            UIButton *button = (UIButton *)cell.accessoryView;
            
            UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
            [button setBackgroundImage:newImage forState:UIControlStateNormal];
            
            if (tableView == self.searchDisplayController.searchResultsTableView) {
                [self.searchDisplayController.searchResultsTableView reloadData];
                [selectedRow addObject:item];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)]) {
                [self.delegate numberOfRowsSelected:1 
                                           withData:[NSArray arrayWithObject:[item valueForKey:@"telephoneSelected"]]
                                        andDataType:requestData];
            }
        }
    }
}

#pragma mark- AlertTableViewDelegate delegate method

- (void)didSelectRowAtIndex:(NSInteger)row 
                    section:(NSInteger)section
                withContext:(id)context
                       text:(NSString *)text 
                    andItem:(NSMutableDictionary *)item
                        row:(int)rowSelected
{
    if ([text isEqualToString:@"-1"]) {
        selectedItem = nil;
        return;
    } else if ([text isEqualToString:@"-2"]) {
        (requestData == DATA_CONTACT_TELEPHONE) ? [selectedItem setValue:@"" forKey:@"telephoneSelected"] : [selectedItem setValue:@"" forKey:@"emailSelected"];
        [selectedItem setObject:[NSNumber numberWithBool:NO] forKey:@"checked"];
        [selectedItem setValue:@"-1" forKey:@"rowSelected"];
        UITableViewCell *cell = [selectedItem objectForKey:@"cell"];
        UIButton *button = (UIButton *)cell.accessoryView;
        
        UIImage *newImage = [UIImage imageNamed:@"unchecked.png"];
        [button setBackgroundImage:newImage forState:UIControlStateNormal];
    } else {
        (requestData == DATA_CONTACT_TELEPHONE) ? [selectedItem setValue:text forKey:@"telephoneSelected"] : [selectedItem setValue:text forKey:@"emailSelected"];
        [selectedItem setObject:[NSNumber numberWithBool:YES] forKey:@"checked"];
        
        UITableViewCell *cell = [selectedItem objectForKey:@"cell"];
        UIButton *button = (UIButton *)cell.accessoryView;
        
        UIImage *newImage = [UIImage imageNamed:@"checked.png"];
        [button setBackgroundImage:newImage forState:UIControlStateNormal]; 
        
        if (self.currentTable == self.searchDisplayController.searchResultsTableView) {
            [self.searchDisplayController.searchResultsTableView reloadData];
            [selectedRow addObject:selectedItem];
        }
    }
    
    if (self.currentTable == self.searchDisplayController.searchResultsTableView) {
        [filteredListContent replaceObjectAtIndex:rowSelected withObject:item];
	} else {
        NSMutableArray *obj=nil;
        if (activated.count==0) {
            obj=[[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:section]];
        } else {
            obj=[[duplicateRemovedArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:section]];

        }
    }

    selectedItem = nil;
    
    if (!showModal)  {
        if ([self.delegate respondsToSelector:@selector(numberOfRowsSelected:withData:andDataType:)]) {
            [self.delegate numberOfRowsSelected:1 
                                       withData:[NSArray arrayWithObject:[item valueForKey:@"telephoneSelected"]]
                                    andDataType:requestData];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
        return [self.filteredListContent count];
	
	int i = 0;
	NSString *sectionString = [arrayLetters objectAtIndex:section];
	
	NSArray *array=nil;
    if (activated.count==0) {
        array= (NSArray *)[[dataArray objectAtIndex:0] valueForKey:sectionString];

    } else {
        array=(NSArray *)[[duplicateRemovedArray objectAtIndex:0]valueForKey:sectionString];
    }
    
	for (NSDictionary *dict in array) {
		NSString *name = [dict valueForKey:@"name"];
		name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
		
		if (![self startsWithLetter:name]) {
			i++;
		} else {
			if ([[[name substringToIndex:1] uppercaseString] isEqualToString:[arrayLetters objectAtIndex:section]])  {
				i++;
			}
		}
	}
	
	return i;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
	
    return arrayLetters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
	
    return [arrayLetters indexOfObject:title];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
	
	return [arrayLetters count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section]==0) {
        return 0;
    } else {
        return 20;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{	
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"";
    }
	
	return [arrayLetters objectAtIndex:section];
}

#pragma mark- Content Filtering

- (void)displayChanges:(BOOL)yesOrNO
{
	int elements = [filteredListContent count];
	NSMutableArray *selected = [NSMutableArray new];
	for (int i = 0; i < elements; i++) {
		NSMutableDictionary *item = (NSMutableDictionary *)[filteredListContent objectAtIndex:i];
		
		BOOL checked = [[item objectForKey:@"checked"] boolValue];
		if (checked) {
			[selected addObject:item];
		}
	}
	
	for (int i = 0; i < [arrayLetters count]; i++) {
		NSMutableArray *obj =Nil;
        if (activated.count==0) {
            obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];

        } else {
            obj = [[duplicateRemovedArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];

        }
        
		for (int x = 0; x < [obj count]; x++) {
			NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
            
			if (yesOrNO) {
				for (NSDictionary *d in selected) {
					if (d == item) {
						[item setObject:[NSNumber numberWithBool:yesOrNO] forKey:@"checked"];
					}
				}
			} else {
				for (NSDictionary *d in selectedRow) {
					if (d == item) {
						[item setObject:[NSNumber numberWithBool:yesOrNO] forKey:@"checked"];
					}
				}
			}
		}
	}
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	selectedRow = [NSMutableArray new];
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	selectedRow = nil;
	[self displayChanges:NO];
	[self.searchDisplayController setActive:NO];
	[self.table reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self displayChanges:YES];
	[self.searchDisplayController setActive:NO];
	[self.table reloadData];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString*)scope
{
	[self.filteredListContent removeAllObjects];
    
	for (int i = 0; i < [arrayLetters count]; i++) {
		NSMutableArray *obj =Nil;
        if (activated.count==0) {
            obj = [[dataArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];

        } else {
            obj = [[duplicateRemovedArray objectAtIndex:0] valueForKey:[arrayLetters objectAtIndex:i]];

        }
       
		for (int x = 0; x < [obj count]; x++) {
			NSMutableDictionary *item = (NSMutableDictionary *)[obj objectAtIndex:x];
			
			NSString *name = [[item valueForKey:@"name"] lowercaseString];
			name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
			
			NSComparisonResult result = [name compare:[searchText lowercaseString] options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
			if (result == NSOrderedSame) {
				[self.filteredListContent addObject:item];
			}
		}
	}
}

#pragma mark- UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

@end