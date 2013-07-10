//
//  ContactActionMenuController.m
//  pekko
//
//  Created by Brandon Eum on 4/20/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "ContactActionMenuController.h"

@interface ContactActionMenuController ()

@end

@implementation ContactActionMenuController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hide the view and set it out of sight upon load
    [self.view setHidden:YES];
    float height  = self.view.frame.size.height;
    CGRect window = [[UIScreen mainScreen] bounds];
    float width   = self.view.frame.size.width;
    float yOrigin = (window.size.height + height);
    [self.view setFrame:CGRectMake(0, yOrigin, width, height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupView];
}

#pragma mark - Setup the view

- (void) setupView
{
    // Setup the view using the contact information
    name.text   = _contact.name;
    status.text = _contact.msg;
    
    if (_contact.photo) {
        [pictureBtn setImage:_contact.photo forState:UIControlStateNormal];
    }
    
    // Set the mood of the user
    mood.image = [UIImage imageNamed:_contact.status];

    if ([_contact.type intValue] == 0) {
        mood.hidden = NO;
    } else {
        mood.hidden = YES;
    }
    
    // Set the up-for activities
    NSArray *buttons = [[NSArray alloc] initWithObjects:
                        b1, b2, b3, b4, b5, b6, b7, b8, b9, nil];
    
    // Hide all the buttons
    for (UIButton *btn in buttons) {
        [btn setHidden:YES];
    }
    
    // Set the images of the buttons and unhide them according to the user's up-for
    // activities
    int i = 0;
    for (NSString *activity in _contact.upForActivities) {
        UIButton *btn = [buttons objectAtIndex:i];
        [btn setHidden:NO];
        
        NSMutableString *imgName = [[NSMutableString alloc] initWithString:@"upfor-"];
        [imgName appendFormat:@"%@.png", activity];
        UIImage *img = [UIImage imageNamed:imgName];
        
        [btn setImage:img forState:UIControlStateNormal];
        i++;
    }
}

#pragma mark - Show and hide

// Set the contact and show the view
// Let viewWillAppear setup the view because you have to wait for the view to
// load before trying to manipulate it
- (void) showWithContact:(PKOContact *)contact
{
    _contact = contact;
    
    // Move the view into the visible area
    [self.view setHidden:NO];
    [self setupView];
    [UIView animateWithDuration:0.5 animations:^{
        float height  = self.view.frame.size.height;
        CGRect window = [[UIScreen mainScreen] bounds];
        float width   = self.view.frame.size.width;
        float yOrigin = window.size.height - (height + 20);
        [self.view setFrame:CGRectMake(0, yOrigin, width, height)];
    }];
}

- (void) hideWithCallback:(PKOGenericCallback)callback
{
    // set the view below the screen then hide it
    [UIView animateWithDuration:0.5
                     animations:^{
                         float height  = self.view.frame.size.height;
                         CGRect window = [[UIScreen mainScreen] bounds];
                         float width   = self.view.frame.size.width;
                         float yOrigin = (window.size.height + height);
                         [self.view setFrame:CGRectMake(0, yOrigin, width, height)];
                     }
                     completion:^(BOOL finished) {
                         [self.view setHidden:YES];
                         callback();
                     }
     ];
}

#pragma mark - Actions

- (IBAction) showSMSView:(id)sender
{
    [delegate showSMSView:_contact];
}

- (IBAction) showPhoneView:(id)sender
{
    [delegate showPhoneView:_contact];
}


@end
