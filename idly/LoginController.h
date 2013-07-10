//
//  LoginController.h
//  NewWorld
//
//  Created by Divakar Srinivasan on 12/18/12.
//

#import <UIKit/UIKit.h>
#import "PKORequestManager.h"

@protocol LoginControllerDelegate <NSObject>

- (void) didCreateAccount:(NSDictionary *)userInfo;

@end

@interface LoginController : UIViewController <PKORequestManagerDelegate>
{
    IBOutlet UITextField *email;
    IBOutlet UITextField *password;
    NSUserDefaults *prefs;
    int loginStatus;
    
    __weak id<LoginControllerDelegate> delegate;
    PKORequestManager *requestManager;
}

@property (nonatomic, weak) id delegate;

-(IBAction)backGroundTouched:(id)sender;
-(IBAction)textFieldReturn:(id)sender;
-(IBAction)loginButtonClicked:(id)sender;
-(IBAction)cancelButtonClicked:(id)sender;

- (void) showView;
- (void) dismissView;
@end
