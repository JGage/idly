//
//  MyAlert.h
//  draaaw
//
//  Created by Rakesh on 05/11/2012.
//

#import <UIKit/UIKit.h>

#import "PKODefinitions.h"
#import "PKORequestManager.h"

@interface PendingRequestAlertController:UIViewController<PKORequestManagerDelegate>
{
    PKORequestManager *requestManager;
    __weak UIViewController<PKORequestManagerDelegate> *parentController;
    PKOGenericCallback hideCallback;
    NSString *requestUsername;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIActivityIndicatorView *indicator;
}

@property (nonatomic, weak) UIViewController<PKORequestManagerDelegate> *parentController;
@property (nonatomic, copy) PKOGenericCallback hideCallback;
@property (nonatomic, strong) NSString *requestUsername;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *imageView;


- (void) showWithCallback:(void (^)(void))callback;
- (void) show;
- (void) hide;

- (IBAction)accept:(id)sender;
- (IBAction)ignore:(id)sender;

@end