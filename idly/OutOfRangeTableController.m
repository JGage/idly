//
//  OutOfRangeTableController.m
//  pekko
//
//  Created by Brandon Eum on 4/7/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "OutOfRangeTableController.h"

@interface OutOfRangeTableController ()

@end

@implementation OutOfRangeTableController

@synthesize delegate, outOfRangeContacts, hideCallback;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        tableController = [[ContactsTableController alloc] init];
        [tableController setDelegate:self];
        [tableController setShouldHideAccessory:YES];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hide the view upon loading
    [self.view setHidden:YES];
    
    // Set the view off screen to the right
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float width = self.view.frame.size.width;
    self.view.frame = CGRectMake(screenRect.size.width, 0, width, screenRect.size.height);
    
    // Set the size of the table view within the view
    [self.view addSubview:tableController.tableView];
    tableController.height = self.view.frame.size.height;
    tableController.width  = self.view.frame.size.width;

}

#pragma mark - Show and Hide the View

- (void) showWithCallback:(void (^)(id contact))callback
{
    [self setHideCallback:callback];
    [self show];
}

- (void) show
{
    // Show the view
    [self.view setHidden:NO];
    
    // Animations - Roll left
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float width = self.view.frame.size.width;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setFrame:CGRectMake(screenRect.size.width - width, 0, width, screenRect.size.height)];
    } completion:^(BOOL finished) {
        // Nothing to do
    }];
}

- (void) hideWithContact:(PKOContact *)contact
{
    [UIView animateWithDuration:0.5 animations:^{
        // Set the view off screen to the right
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float width = self.view.frame.size.width;
        
        self.view.frame = CGRectMake(screenRect.size.width, 0, width, screenRect.size.height);
    } completion:^(BOOL finished) {
        // Hide the view
        [self.view setHidden:YES];
        hideCallback(contact);
    }];
}


#pragma mark - Table view data source

- (void) reloadContacts:(NSArray *)contacts
{
    [tableController removeAllContacts];
    
    for (PKOContact *contact in contacts) {
        [tableController addContact:contact];
    }
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return [outOfRangeContacts count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    // Add the contact's name
//    PKOContact *contact = [outOfRangeContacts objectAtIndex:indexPath.row];
//    
//    cell.textLabel.text = contact.name;
//    
//    return cell;
//}

#pragma mark - Table view delegate

- (void) didSelectContact:(PKOContact *)contact
{
    [self hideWithContact:contact];
}

@end
