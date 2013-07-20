//
//  ContactsTableController.m
//
//  Created by Brandon Eum on 2/26/13.
//

#import "ContactsTableController.h"


@implementation ContactsTableController

@synthesize delegate, activationQueueContacts, filteredListContent, activeContacts;
@synthesize height, width, shouldHideAccessory;


#pragma mark- Standard
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
        
        arrayLetters=[[NSArray alloc]
                      initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                      @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R",
                      @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil
                      ];
        selectedContacts       = [NSMutableDictionary new];
        alphabetwiseDictionary = [NSMutableDictionary new];
        activeContacts = [[NSMutableArray alloc] init];
        height = 0;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    if (height == 0) {
        height = self.view.frame.size.height;
        width  = self.view.frame.size.width;
    }
    
    // Set the table to the bottom of the screen
    if (!yorigin) {
        yorigin = (self.view.superview.frame.size.height - height);
    }
    
    [self.view setFrame:CGRectMake(0, yorigin, width, 210)];
    [super viewWillAppear:animated];
}

#pragma mark- Manipulating the table data

- (void) removeAllContacts
{
    [activeContacts removeAllObjects];
    [self.tableView reloadData];
}

- (void) addContact:(PKOContact *)contact
{
    [activeContacts addObject:contact];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:activeContacts.count-1 inSection:0];
    NSArray *rows = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:NO];
}

- (void) updateContact:(NSString *)username
{
    NSInteger index = -1;
    NSInteger count = 0;
    for (PKOContact *contact in activeContacts) {
        if ([contact.username isEqualToString:username]) {
            index = count;
            break;
        }
        count++;
    }
    
    // If we found the user to update
    if (index != -1) {
        PKOContact *contact = [activeContacts objectAtIndex:index];
        [activeContacts removeObjectAtIndex:index];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NSArray *rows = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:YES];
        [self addContact:contact];
    }
}

// sort activated users in alphabetical order
- (void) groupContactsForSection
{
    return;
    for (int i = 0; i < [arrayLetters count]; i++) {
        NSMutableArray *array = [NSMutableArray new];
        
        for (PKOContact *temp in activeContacts) {
            if ([[[temp.name substringToIndex:1] uppercaseString] isEqualToString:[arrayLetters objectAtIndex:i]]) {
                [array addObject:temp];
            }
        }
        
        [alphabetwiseDictionary setValue:array forKey:[arrayLetters objectAtIndex:i]];
    }
}

#pragma mark- Table view - Setting up sections

// Section the table by alphabet
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//return [arrayLetters count];
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

// Set the number of rows in a particular section
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [activeContacts count];
}


#pragma mark- Table view - Setting up the table cells


// Determine the height for each contact entry
- (CGFloat)     tableView:(UITableView *)tableView
  heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (CGFloat)        tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    PKOContact *contact = [activeContacts objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
        
        // Setup the accessory button for activation/deactivation
        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [accessoryButton addTarget:self
                            action:@selector(checkButtonTapped:event:)
                  forControlEvents:UIControlEventTouchUpInside
        ];
        
        UIImage *image = [UIImage imageNamed:@"unselected.png"];
        [accessoryButton setBackgroundImage:image forState:UIControlStateNormal];
        
        CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        accessoryButton.frame = frame;
        cell.accessoryView    = accessoryButton;
        
        // Load the custom content view
        ContactTableCellView *view = [[ContactTableCellView alloc] init];
        view.tag = 33;
        [cell.contentView addSubview:view];
    }
    
    // Update this cell with the appropriate content
    ContactTableCellView *view = (ContactTableCellView *)[cell.contentView viewWithTag:33];
    view.name.text = contact.name;
    view.msg.text  = contact.msg;
    
    // Either show the contact's photo or reset to the default image
    if (contact.photo) {
        view.profileImg.image = contact.photo;
    } else {
        view.profileImg.image = [UIImage imageNamed:@"user-pic.png"];
    }

    UIButton *btn = (UIButton *)cell.accessoryView;
    [btn setHidden:YES];
    [view.requested setHidden:NO];
    
    // Set the checkbutton
    if (shouldHideAccessory){
        // Leave the button hidden
    } else if ([contact.activation_status isEqualToString:@"a"] || [contact.activation_status isEqualToString:@"r"]) {
        [btn setHidden:NO];
        [view.requested setHidden:YES];
        UIImage *image = [contact.display_status isEqualToString:@"v"] ? [UIImage imageNamed:@"selected.png"] : [UIImage imageNamed:@"unselected.png"];
        [btn setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    // Set the mood of the user or hide it if they are pending
    if ([contact.activation_status isEqualToString:@"a"] && [contact.type intValue] == 0) {
       [view.status setHidden:NO];
       view.status.image = [UIImage imageNamed:contact.status];
    } else {
       [view.status setHidden:YES];
    }
    
    // Set the up-for activities
    NSArray *buttons = [[NSArray alloc] initWithObjects:
                        view.b1, view.b2, view.b3, view.b4, view.b5, view.b6,
                        view.b7, view.b8, view.b9, nil];
    
    // Hide all the buttons
    for (UIButton *btn in buttons) {
        [btn setHidden:YES];
    }

    int i = 0;
    for (NSString *activity in contact.upForActivities) {
        UIButton *btn = [buttons objectAtIndex:i];
        [btn setHidden:NO];
        
        NSMutableString *imgName = [[NSMutableString alloc] initWithString:@"upfor-"];
        [imgName appendFormat:@"%@.png", activity];
        UIImage *img = [UIImage imageNamed:imgName];
        
        [btn setImage:img forState:UIControlStateNormal];
        i++;
    }

    return cell;
}

#pragma mark- Table view delegate - Interacting


- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Make this show details or something
	//[self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    
    // Recenter the map on the contact
    PKOContact *contact = [activeContacts objectAtIndex:indexPath.row];
    [self.delegate didSelectContact:contact];
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// User checked the contact
- (void) checkButtonTapped:(id)sender
                     event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];

    if (indexPath != nil) {
        [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void) tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    PKOContact *contact = [activeContacts objectAtIndex:indexPath.row];
    contact.isVisible = ![contact isVisible];

    NSString *displayStatus = ([contact.display_status isEqualToString:@"v"] ? @"e" : @"v");
    [requestManager updateContact:contact.username
                 withRelationship:nil
                      withDisplay:displayStatus
     ];
     

    UITableViewCell *cell     = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *accessoryButton = (UIButton *)[cell accessoryView];
    UIImage *newImage = (contact.isVisible) ? [UIImage imageNamed:@"selected.png"] : [UIImage imageNamed:@"unselected.png"];
    [accessoryButton setBackgroundImage:newImage forState:UIControlStateNormal];
}


- (void) deleteActivatedUser
{
    /*
    UITableView *tblView = (UITableView *)self.view;
	if(self.editing)
	{
		[super setEditing:NO animated:NO];
		[tblView setEditing:NO animated:NO];
		[tblView reloadData];
        [editButton setTitle:@"Edit" forState:UIControlStateNormal];
	}
	else
	{
		[super setEditing:YES animated:YES];
		[tblView setEditing:YES animated:YES];
		[tblView reloadData];
        [editButton setTitle:@"Done" forState:UIControlStateNormal];
	}
     */
}

- (IBAction) editButtonTapped:(id)sender
{
    [self deleteActivatedUser];
}

// When a user selects all contacts, try to activate all of them
- (IBAction) selectAllContacts:(id)sender
{

}

- (BOOL)       tableView:(UITableView *)tableView
   canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Do not allow editing for the out of range contacts
    if (shouldHideAccessory) {
        return UITableViewCellEditingStyleNone;
    } else  {
        return UITableViewCellEditingStyleDelete;
    }
}


// Save the user as deleted in the backend
- (void)     tableView:(UITableView *)aTableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PKOContact *contact = [activeContacts objectAtIndex:indexPath.row];
        contact.isVisible = ![contact isVisible];

        // Update the relationship to be rejected
        [requestManager updateContact:contact.username
                     withRelationship:@"x"
                          withDisplay:nil
         ];
    }
}

#pragma mark- PKORequestManagerDelegate Methods

- (void) requestDidReceiveForbidden
{
    // TODO: Show the signup view by messaging upward
}

- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
    // Nothing to do here
}

- (void) didUpdateContact:(NSDictionary *)contact
{
    [self.delegate didUpdateContactStatus];
}



@end
