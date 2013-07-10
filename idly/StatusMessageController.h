//
//  StatusMessageController.h
//
//  Created by Brandon Eum on 2/18/13.
//

#import <UIKit/UIKit.h>
#import "PKORequestManager.h"
#import "PKOUserContainer.h"
#import "UpForController.h"

@protocol StatusMessageControllerDelegate <NSObject>

- (void) didDismissStatusMessageView;

@end


@interface StatusMessageController : UIViewController <UITextViewDelegate, PKORequestManagerDelegate>
{
    __weak UIViewController <StatusMessageControllerDelegate, PKORequestManagerDelegate> *placeController;
    IBOutlet UITextView *textArea;
    PKORequestManager *requestManager;
    
    PKOUserContainer *user;
    UpForController *upForController;
    
    NSArray *upForButtons;
    __weak IBOutlet UIButton *b1, *b2, *b3, *b4, *b5, *b6, *b7, *b8, *b9;
}

@property (nonatomic, weak) UIViewController *placeController;
@property (nonatomic, strong) PKORequestManager *requestManager;


- (IBAction) addUpForActivityClicked:(id)sender;

- (IBAction) saveClicked:(id)sender;
- (IBAction) cancelClicked:(id)sender;

- (void) resetUpForButtonsFromUser;
- (void) showViewWithNewText:(NSString *)text;
- (void) dismissView;

@end