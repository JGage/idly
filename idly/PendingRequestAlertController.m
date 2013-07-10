//
//  PendingRequestAlertController.m
//

#import "PendingRequestAlertController.h"

@implementation PendingRequestAlertController
@synthesize nameLabel, imageView, hideCallback, requestUsername, parentController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
        [self setHideCallback:^{}];
    }
    return self;
}

#pragma mark- View Lifcycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(20,50,self.view.frame.size.width, self.view.frame.size.height)];
    [self.view setHidden:YES];
    [indicator setHidden:YES];
}

#pragma mark- Accept/Decline

- (IBAction) accept:(id)sender
{
    [indicator setHidden:NO];
    [indicator startAnimating];
    [requestManager updateContact:requestUsername withRelationship:@"a" withDisplay:@"e"];
}

- (IBAction) ignore:(id)sender
{
  // Update the relationship to be rejected
  [requestManager updateContact: requestUsername
               withRelationship:@"x"
                    withDisplay:nil
   ];
    [self hide];
}

#pragma mark- Show/Hide

- (void)showWithCallback:(void (^)(void))callback
{
    [self setHideCallback:callback];
    [self show];
}

- (void)show
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setHidden:NO];
    }];
}

- (void)hide
{
    hideCallback();
    [indicator setHidden:YES];
    [indicator stopAnimating];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setHidden:YES];
    }];
}

#pragma mark- PKORequestManagerDelegateMethods
- (void) requestDidReceiveNotFound {}
- (void) requestDidReceiveBadRequest:(NSDictionary *)response {}

- (void) requestDidReceiveForbidden
{
    [parentController requestDidReceiveForbidden];
}

- (void) didUpdateContact:(NSDictionary *)contact
{
    [self hide];
    // TODO: Should there be some sort of success callback?
}
@end