//
//  ViewController.h
//  NewWorld
//
//  Created by Divakar Srinivasan on 11/1/12.
//

#import <UIKit/UIKit.h>
#import "LoginController.h"
#import "PKORequestManager.h"

@protocol SignupControllerDelegate <NSObject>

- (void) showPlacesViewController;

@end

@interface SignupController : UIViewController
<
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate,
        UIActionSheetDelegate,
        UITextFieldDelegate,
        LoginControllerDelegate,
        PKORequestManagerDelegate
>
{
    IBOutlet LoginController *loginController;
    IBOutlet UITextField *email, *firstName, *lastName, *password, *phoneNo;
    IBOutlet UIButton * avatarButton;

    NSUserDefaults *prefs;
    UIImageView *avatar;
    CGSize startingSize;
    
    int loginStatus;
    BOOL isNotPhotoPicked;

    __weak id<SignupControllerDelegate> delegate;
    PKORequestManager *requestManager;
}


@property(nonatomic, retain) NSData* imageData;
@property(nonatomic, weak)   id delegate;

-(IBAction)signUpButtonClicked:(id)sender;
-(IBAction)avatarClicked:(id)sender;
-(IBAction)backGroundTouched:(id)sender;
-(IBAction)textFieldReturn:(id)sender;
-(void)textFieldDidBeginEditing:(UITextField *)textField;
-(void)moveViewPositionTo : (NSInteger) pos;
-(BOOL) NSStringIsValidEmail:(NSString *)checkString;
-(IBAction)loginButtonClicked:(id)sender;


@end
