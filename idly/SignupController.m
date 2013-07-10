//
//  SignupController.m
//
//  Controls account creation
//


#import "SignupController.h"
#import "PKOAppDelegate.h"

@implementation SignupController

@synthesize imageData, delegate;

#pragma mark- Init, dealloc, and other standard methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark- View Handlers

- (void)viewDidLoad
{
    isNotPhotoPicked = true;
    self.view.backgroundColor = [
        UIColor colorWithPatternImage: [
            UIImage imageWithContentsOfFile: [
                [[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"app-bg.png"
            ]
        ]
    ];
    
    [super viewDidLoad];
    
    prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs stringForKey:@"api_key"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showPlacesViewController" object:nil];
    }
    
    // Add the view for the login controller
    [loginController setDelegate:self];
    [self.view addSubview:loginController.view];
}

#pragma mark- Text Editing and Form Operations

// keyboard hides when background touched
-(IBAction)backGroundTouched:(id)sender{
    [firstName resignFirstResponder];
    [password resignFirstResponder];
    [email resignFirstResponder];
    [phoneNo resignFirstResponder];
    [self moveViewPositionTo:20];
}

// keyboard hide
-(IBAction)textFieldReturn:(id)sender{
    [sender resignFirstResponder];
}

// email validation
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; 
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}



// Restrict entry to format 123-456-7890
- (BOOL) textField:(UITextField *)textField  shouldChangeCharactersInRange:(NSRange)range 
 replacementString:(NSString *)string {
    if (textField == email) {
        return YES;
    }
    // All digits entered
    if (range.location == 12) {
        return NO;
    }
    
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]]) {
        return NO;
    }
    
    // Auto-add hyphen before appending 4rd or 7th digit
    if (range.length == 0 &&
        (range.location == 3 || range.location == 7)) {
        textField.text = [NSString stringWithFormat:@"%@-%@", textField.text, string];
        return NO;
    }
    
    // Delete hyphen when deleting its trailing digit 
    if (range.length == 1 &&
        (range.location == 4 || range.location == 8))  {
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        return NO;
    }
    
    return YES;
}

// moving view
-(void)moveViewPositionTo : (NSInteger) pos {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35f];
    CGRect frame = self.view.frame;
    frame.origin.y = pos;
    [self.view setFrame:frame];
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self moveViewPositionTo: -textField.frame.origin.y+150 ];
}

#pragma mark- Buttons Clicked


// first time user registration
-(IBAction)signUpButtonClicked:(id)sender{
    
    // field validation
    // TODO: Fix UI Alert View
    if ((firstName.text.length== 0|| password.text.length ==0 || email.text.length ==0 || lastName.text.length==0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                   message:@"A required filed is empty"
                                  delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil
        ];
        [alert show];
		return;
	}
    if (phoneNo.text.length<10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Phone number is invalid"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil
                             ];
        [alert show];
		return;
    }
    if (![self NSStringIsValidEmail:email.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"The email you have specified is invalid"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil
                              ];
        [alert show];
		return;
    }
    /* TODO: I think it's OK to not require the photo, but should provide a way to replace later
     
     if (isNotPhotoPicked) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"A required filed is empty"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil
                              ];
        [alert show];
		return;
    }*/
    
    //  Account registration
    NSArray *keys = [NSArray arrayWithObjects:
                     @"user_name",
                     @"first_name",
                     @"last_name",
                     @"phone",
                     @"email",
                     @"enc_password",
                     nil
                     ];
    NSArray *objects = [NSArray arrayWithObjects:
                        [email text],
                        [firstName text],
                        [lastName text],
                        [phoneNo text],
                        [email text],
                        [password text],
                        nil
                        ];
    NSDictionary *data = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [requestManager createAccountWithData:data];
}

// already existing user entry and navigating to login entry screen
- (IBAction)loginButtonClicked:(id)sender {
    [loginController showView];
}

- (void) showLoginScreen
{
    [loginController showView];
}

#pragma mark- Image selection methods

// calling actionsheet
-(IBAction)avatarClicked:(id)sender{
    UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:@"Choose a Pic:"
                                                             delegate:self cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Photo Album",@"Take a pic",nil];
    [cameraSheet showInView:self.view];
    
}

// action sheet from bottom of the screen
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==2) {
        return;
    }
    UIImagePickerController *myImagePicker = [[UIImagePickerController alloc] init];
    myImagePicker.delegate = self;
    myImagePicker.allowsEditing = YES;
    if (buttonIndex==1) {
        myImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self presentViewController:myImagePicker animated:YES completion:^{}];
    //[myImagePicker release];
    
}

// picking image from camera or photo album
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    
	[self dismissModalViewControllerAnimated:YES];
    
    UIImage *newImage;
    UIGraphicsBeginImageContext(CGSizeMake(114,114)); 
    [image drawInRect:CGRectMake(0, 0,114,114)];
    newImage = UIGraphicsGetImageFromCurrentImageContext(); 
    UIGraphicsEndImageContext();
    self.imageData=UIImageJPEGRepresentation(newImage, 1); 
    [avatarButton setImage:image forState:UIControlStateNormal];
    isNotPhotoPicked = false;

}

#pragma mark- PKORequestManagerDelegate Methods

- (void) requestDidReceiveForbidden
{
    NSLog(@"SC: This should not have happened");
}

- (void) requestDidReceiveBadRequest: (NSDictionary *)response
{
    NSLog(@"SC: Received 400 response");
    NSLog(@"SC: %@", response);
    /*
    if ([[response substringFrom:56 to:60] isEqualToString:@"phon"]) {

        return;
    } else if ([[response substringFrom:56 to:60] isEqualToString:@"user"]) {
        UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:@"Oops!"
                      message:@"An account with this email already exists"
                     delegate:self
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil
        ];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:@"Oops!"
            message:@"An account with this email already exists"
            delegate:self
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil
        ];
        [alert show];
    }
*/
    UIAlertView *alert = [[UIAlertView alloc]
        initWithTitle:@"Oops!"
        message:@"We're sorry we couldn't create your account"
        delegate:self
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil
    ];
    [alert show];
    return;
}

// Sets the new user into the preferences and switches to the places view
// Also called by the login controller because when you are logging in, the
// action is the same as when you are creating an account
- (void) didCreateAccount: (NSDictionary *)userInfo
{
    NSString *api_key = [userInfo valueForKey:@"api_key"];
    [prefs setObject:api_key forKey:@"api_key"];
    [prefs setObject:[userInfo valueForKey:@"user_name"] forKey:@"username"];
    [prefs setObject:[userInfo valueForKey:@"first_name"] forKey:@"first_name"];
    [prefs setObject:[userInfo valueForKey:@"last_name"] forKey:@"last_name"];
    [prefs setObject:password.text forKey:@"password"];
    [prefs setObject:phoneNo.text forKey:@"phone"];
    
    // set the new api key in the request manager
    [[requestManager user] setApikey:api_key];
    [[requestManager user] setUsername:[userInfo valueForKey:@"user_name"]];

    // Only upload a photo if it is selected
    if (!isNotPhotoPicked) {
        [requestManager uploadProfileImage:self.imageData];
    }
    
    [delegate showPlacesViewController];
}

@end
