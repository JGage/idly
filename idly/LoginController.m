//
//  LoginController.m
//  NewWorld
//
//  Created by Divakar Srinivasan on 12/18/12.
//

#import "LoginController.h"

@implementation LoginController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:
                                                                [[[NSBundle mainBundle] resourcePath] 
                                                                 stringByAppendingPathComponent:@"app-bg.png"]]];
    
    // Do any additional setup after loading the view from its nib.
    if (!requestManager) {
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
    }
    
    // Set the frame to be hidden by default and below the visible field
    // so it can slide up when it appears
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    self.view.frame = CGRectMake(0, height, width, height);
    self.view.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    email.text = @"";
    password.text = @"";
}


#pragma mark- Utility Methods

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

#pragma mark- Button Actions

// keyboard hides when background touched
-(IBAction)backGroundTouched:(id)sender{
    [email resignFirstResponder];
    [password resignFirstResponder];

}

// keyboard hides when return button tapped
-(IBAction)textFieldReturn:(id)sender{
    [sender resignFirstResponder];
}

// takes to home screen (map screen)
-(IBAction)loginButtonClicked:(id)sender
{
    // field validation
    if (email.text.length == 0 || password.text.length == 0) {
        //TODO: Replace with alert
        //[UIAlertview_Addition alert:@"Username and Password must not be empty" withTitle:@"Error"];
		return;
    }
    if (![self NSStringIsValidEmail:email.text]) {
        //TODO: Replace with alert
  //      [UIAlertview_Addition alert:@"Invalid Email" withTitle:@"Error"];
		return;
    }

    [requestManager loginWithUsername:[email text] withPassword:[password text]];
}

// dismissing view and taking into previous screen
-(IBAction)cancelButtonClicked:(id)sender
{
    [self dismissView];
}

#pragma mark- Show/Hide View

- (void) showView
{
    self.view.hidden = NO;
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    [UIView animateWithDuration:0.5
        animations:^{
            self.view.frame = CGRectMake(0, 0, width, height);
        }
        completion:^(BOOL finished) {
            // Do nothing for now
        }
    ];
}

- (void) dismissView
{
    self.view.hidden = NO;
    
    CGFloat width  = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    [UIView animateWithDuration:0.5
         animations:^{
             self.view.frame = CGRectMake(0, height, width, height);
         }
         completion:^(BOOL finished) {
             // Do nothing for now
         }
    ];
}

#pragma mark- PKORequestManager Delegate Methods

- (void) requestDidReceiveForbidden
{
    // TODO: Replace with alert
    //[UIAlertview_Addition alert:@"The given user name or password was incorrect, please try again." withTitle:@"Error"];
    return;
}

- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
    // Not sure what to do if this happens
}

- (void)didLogin:(NSDictionary *)userInfo
{
    NSString *api_key = [userInfo valueForKey:@"api_key"];
   
    [prefs setObject:[userInfo valueForKey:@"user_name"] forKey:@"username"];
    [prefs setObject:api_key forKey:@"api_key"];
    [prefs setObject:[userInfo valueForKey:@"first_name"] forKey:@"first_name"];
    [prefs setObject:[userInfo valueForKey:@"last_name"] forKey:@"last_name"];
    [prefs setObject:password.text forKey:@"password"];

    // Hide the view
    [self dismissView];
    
    // Allow the parent signupController to handle the response
    [delegate didCreateAccount:userInfo];
}

@end
