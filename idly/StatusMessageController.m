//
//  StatusMessageController.m
//  NewWorld
//
//  Created by Brandon Eum on 2/18/13.
//

#import "StatusMessageController.h"
#import <QuartzCore/QuartzCore.h>

@implementation StatusMessageController

@synthesize placeController, requestManager;

#pragma mark- Init and standard methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
        
        upForController = [[UpForController alloc] init];
        
        user = [PKOUserContainer sharedContainer];
        upForButtons = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark- View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [textArea setDelegate:self];
    [[textArea layer] setBorderColor:[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] CGColor]];
    [[textArea layer] setBorderWidth:1];
    [[textArea layer] setCornerRadius:5];
    
    // Add all 9 buttons to an array for later reference
    upForButtons = nil;
    upForButtons = [[NSArray alloc] initWithObjects: b1, b2, b3, b4, b5, b6, b7, b8, b9, nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetUpForButtonsFromUser];
}

- (void) resetUpForButtonsFromUser
{
    // Set all the up-for buttons to the default nil image
    for (UIButton *btn in upForButtons) {
        [btn setImage:nil forState:UIControlStateNormal];
        [btn setHidden:YES];
    }
    
    // Get all of the selected actvities from the user
    NSSet *activitySet = [user.upforActivities keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        if (obj != nil) {
            return true;
        } else {
            return false;
        }
    }];
    NSArray *activities = [[NSArray alloc] initWithArray:[activitySet allObjects]];
    
    NSInteger i = 0;
    UIButton *btn = nil;
    for (NSString *activity in activities) {
        if (i < [upForButtons count]) {
            btn = [upForButtons objectAtIndex:i];
        
            NSMutableString *imgName = [[NSMutableString alloc] initWithString:@"upfor-"];
            [imgName appendString:activity];
            [imgName appendString:@".png"];
            
            UIImage *img = [UIImage imageNamed:imgName];
            [btn setImage:img forState:UIControlStateNormal];
            [btn setHidden:NO];
            i++;
        } else {
            // Something is wrong, there shouldn't be more activities than place
            // holder buttons
            NSLog(@"ERROR: up for actvities exceeded available buttons");
            break;
        }
    }
}

- (void) showViewWithNewText:(NSString *)text
{
    // TODO: Use dynamic frame sizing
    [self resetUpForButtonsFromUser];
    [textArea setText:text];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(0, 0, 320, 460);
    }];
}

- (void) dismissView
{
    [textArea resignFirstResponder];
    [UIView animateWithDuration:0.5
        animations:^{
            self.view.frame = CGRectMake(0, -460, 320, 460);
        }
        completion:^(BOOL finished){
            [placeController didDismissStatusMessageView];
        }
     ];
}

#pragma mark- UI Interactions

- (IBAction) addUpForActivityClicked:(id)sender
{
    [self.view addSubview:upForController.view];
    [upForController showViewWithCallback:^{
        [self resetUpForButtonsFromUser];
    }];
}

- (IBAction) saveClicked:(id)sender
{
    NSString *text = [textArea text];
    NSString *mood = [user mood];
    mood = (mood) ? mood : @"happy";
    

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:text forKey:@"msg"];
    [dict setObject:mood forKey:@"status"];
    [dict setObject:[NSNumber numberWithInt:1] forKey:@"icon_id"];
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    [requestManager updateStatus:data];
}


- (IBAction) cancelClicked:(id)sender
{
    [self dismissView];
}

- (BOOL) textView:(UITextView *)textView
         shouldChangeTextInRange:(NSRange)range
         replacementText:(NSString *)text
{
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 150) ? NO : YES;
}

#pragma mark- PKORequestManager Methods

- (void) requestDidReceiveForbidden
{
    [self dismissView];
    [placeController requestDidReceiveForbidden];
}

- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
    // Not sure what to do here
}

- (void) didUpdateStatus:(NSDictionary *)status
{
    [self dismissView];
}

@end
