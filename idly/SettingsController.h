//
//  SettingsController.h
//  pekko
//
//  Created by Brandon Eum on 4/21/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PKORequestManager.h"
#import "PKOUserContainer.h"
#import "PKODefinitions.h"

@interface SettingsController : UIViewController
<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIActionSheetDelegate,
    PKORequestManagerDelegate
>
{
    PKORequestManager *requestManager;
    PKOUserContainer *user;
    
    PKOGenericCallback _callback;
    
    __weak IBOutlet UIButton *avatar;
    UIImageView *selectedImage;
    
    
    __weak IBOutlet UILabel *phone, *user_name;
    __weak IBOutlet UITextField *first_name, *last_name, *password;
    
    float originalHeight, originalWidth;
    NSString *temp_pass;
}

- (IBAction) selectProfileImage:(id)sender;
- (IBAction) updateName:(id)sender;
- (IBAction) updatePassword:(id)sender;


- (void) showView;
- (void) resizeView;
- (void) setupView;
- (void) hideWithCallback:(PKOGenericCallback)callback;
- (void) moveViewOutOfFrame;

@end
