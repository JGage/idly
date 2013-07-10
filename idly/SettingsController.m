//
//  SettingsController.m
//  pekko
//
//  Created by Brandon Eum on 4/21/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "SettingsController.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Get an instance of the request manager and the shared user container
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
        user = [PKOUserContainer sharedContainer];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the original height and width
    originalHeight = self.view.frame.size.height;
    originalWidth  = self.view.frame.size.width;
    
    // Hide the view and move it out of frame
    [self.view setHidden:YES];
    [self moveViewOutOfFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Show/Hide the view

- (void) showView
{
    // Move the view into the visible area
    [self.view setHidden:NO];
    [self setupView];
    [UIView animateWithDuration:0.5 animations:^{
        [self resizeView];
    }];
}


// Provide a small helper function to be used elsewhere
- (void) resizeView
{
    //CGRect window = [[UIScreen mainScreen] bounds];
    //float yOrigin = window.size.height - originalHeight - 20;
    float yOrigin = 0;
    [self.view setFrame:CGRectMake(0, yOrigin, originalWidth, originalHeight)];
}

// Set the properties of the view before displaying
- (void) setupView
{
    // Attempt to get the photo from the backend
    // Just in case that didn't work, get the default image
    UIImage *img;
    if (!user.info.photo) {
        img = [requestManager getImageForSelf];
        user.info.photo = img;
    } else {
        img = user.info.photo;
    }
    
    // Just in case that didn't work, get the default image
    
    if (!img) {
        img = [UIImage imageNamed:@"user-pic.png"];
    }

    [avatar setImage:img forState:UIControlStateNormal];
    user_name.text  = user.username;
    phone.text      = user.info.phone;
    first_name.text = user.info.first_name;
    last_name.text  = user.info.last_name;
}

- (void) hideWithCallback:(PKOGenericCallback)callback
{
    [first_name resignFirstResponder];
    [last_name resignFirstResponder];
    [password resignFirstResponder];
    
    // set the view below the screen then hide it
    [UIView animateWithDuration:0.5 animations:^{
        [self moveViewOutOfFrame];
    } completion:^(BOOL finished) {
        [self.view setHidden:YES];
        callback();
    }];
}

// Helper function to ensure that the view is outside the visible area
- (void) moveViewOutOfFrame
{
//    CGRect window = [[UIScreen mainScreen] bounds];
//    float yOrigin = window.size.height + originalHeight;
    float yOrigin = originalHeight * -1;
    [self.view setFrame:CGRectMake(0, yOrigin, originalWidth, originalHeight)];
}


#pragma mark - Update the user's account

- (IBAction) selectProfileImage:(id)sender
{
    // Create a list of choices for the user to pick from the photo album
    // or take a new profile picture
    UIActionSheet *cameraSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Choose a Pic:"
                                       delegate:self
                              cancelButtonTitle:@"Cancel"
                         destructiveButtonTitle:nil
                              otherButtonTitles:@"Photo Album", @"Take a pic", nil];

    [cameraSheet showFromRect:self.view.superview.frame inView:self.view.superview animated:YES];
}

- (IBAction) updateName:(id)sender
{
    // Resign the first responder
    [first_name resignFirstResponder];
    [last_name resignFirstResponder];
    [password resignFirstResponder];
    
    NSArray *info = [[NSArray alloc] initWithObjects:first_name.text, last_name.text, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"first_name", @"last_name", nil];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:info forKeys:keys];
    [requestManager updateAccount:userInfo];
}

- (IBAction) updatePassword:(id)sender
{
    // Resign the first responder
    [first_name resignFirstResponder];
    [last_name resignFirstResponder];
    [password resignFirstResponder];
    
    [requestManager updatePasswordWithUsername:user.username
                                   andPassword:user.password
                                andNewPassword:password.text];
    temp_pass = password.text;
    password.text = nil;
}

#pragma mark - Action Sheet and Image Picker Delegate

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Cancel button clicked
    if (buttonIndex==2) {
        return;
    }
    
    // Create an image picker that can use the camera or the photo album
    UIImagePickerController *myImagePicker = [[UIImagePickerController alloc] init];
    myImagePicker.delegate = self;
    myImagePicker.allowsEditing = YES;
    
    // Use the camera instead of the photo album
    if (buttonIndex == 1) {
        myImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:myImagePicker animated:YES completion:^{}];
}

// Hide the view properly
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    [self resizeView];
}

// picking image from camera or photo album
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
	[self dismissViewControllerAnimated:YES completion:^{}];
    [self resizeView];
    
    if (!image) {
        return;
    }
    
    // Size the image appropriately
    UIImage *newImage;
    UIGraphicsBeginImageContext(CGSizeMake(114,114));
    [image drawInRect:CGRectMake(0, 0,114,114)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
    // Update the picture in the settings area
    [avatar setImage:newImage forState:UIControlStateNormal];
    
    // Trigger the request to the server to update the image
    NSData *imageData = UIImageJPEGRepresentation(newImage, 1);
    [requestManager uploadProfileImage:imageData];
}

#pragma mark - Text field controls

// keyboard hide
-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - PKO Request Manager Delegate Methods

- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
    
}

- (void) requestDidReceiveForbidden
{
    
}

- (void) requestDidReceiveNotFound
{
    
}

- (void) didUpdatePassword:(NSDictionary *)account
{
    [user setPassword:temp_pass];
    temp_pass = nil;
}

- (void) didUpdateAccount:(NSDictionary *)account
{
    user.info.first_name = [account objectForKey:@"first_name"];
    user.info.last_name  = [account objectForKey:@"last_name"];
    [self setupView];
}

// Update the user's photo after uploading it to the server
- (void) didUpdateProfileImage
{
    user.info.photo = [requestManager getImageForSelf];
    [self setupView];
}



@end
