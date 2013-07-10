//
//  UpForController.m
//  pekko
//
//  Created by Brandon Eum on 4/6/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "UpForController.h"

@interface UpForController ()

@end

@implementation UpForController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
        
        user = [PKOUserContainer sharedContainer];
        availableActivities = [[NSArray alloc] initWithObjects:
                               @"coffee", @"food", @"movies",
                               @"deals", @"drinks", @"shopping",
                               @"walk", @"talking", @"seasonal", nil];
        isUpdating = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the frame according to the superview
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.view.frame = screenRect;
    
    // Hide the view upon load
    [self.view setHidden:YES];
    [self.view setAlpha:0];
    
    // Setup whether the images are marked as selected or not
    [self setImagesFromUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UI Control

// Set either the "selected" image or the regular icon based on what the user
// has already selected
- (void) setImagesFromUser
{
    // TODO: Terrible to hard-code it here, but i had trouble with a loop
    UIImage *selected = [UIImage imageNamed:@"upfor-selected.png"];
    
    [coffee setImage:selected forState:UIControlStateSelected];
    [coffee setSelected:([user.upforActivities objectForKey:@"coffee"] != nil)];
    
    
    [food setImage:selected forState:UIControlStateSelected];
    [food setSelected:([user.upforActivities objectForKey:@"food"] != nil)];
    
    [movies setImage:selected forState:UIControlStateSelected];
    [movies setSelected:([user.upforActivities objectForKey:@"movies"] != nil)];
    
    
    [deals setImage:selected forState:UIControlStateSelected];
    [deals setSelected:([user.upforActivities objectForKey:@"deals"] != nil)];
    
    [drinks setImage:selected forState:UIControlStateSelected];
    [drinks setSelected:([user.upforActivities objectForKey:@"drinks"] != nil)];
    
    [shopping setImage:selected forState:UIControlStateSelected];
    [shopping setSelected:([user.upforActivities objectForKey:@"shopping"] != nil)];
    
    
    [walk setImage:selected forState:UIControlStateSelected];
    [walk setSelected:([user.upforActivities objectForKey:@"walk"] != nil)];
    
    [talking setImage:selected forState:UIControlStateSelected];
    [talking setSelected:([user.upforActivities objectForKey:@"talking"] != nil)];
    
    [biking setImage:selected forState:UIControlStateSelected];
    [biking setSelected:([user.upforActivities objectForKey:@"biking"] != nil)];
    
    /*
    for (NSString *activity in availableActivities) {
        NSLog(@"%@", activity);
        UIButton *btn = [buttonDictionary objectForKey:activity];
        if (YES || [user.upforActivities valueForKey:activity]) {
                    NSLog(@"%@", activity);
            [btn setImage:[UIImage imageNamed:@"upfor-selected.png"] forState:UIControlStateSelected];
            [btn setSelected:YES];
        } else {
            NSMutableString *img = [[NSMutableString alloc] initWithString:@"upfor-"];
            [img appendString:activity];
            [img appendString:@".png"];
            [btn setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
        }
    } */
}

- (void) showView
{
    [self setImagesFromUser];
    [self.view setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setAlpha:0.75];
    }];
}

- (void)showViewWithCallback:(void (^)(void))callback
{
    hideCallback = callback;
    [self showView];
}


- (void) dismissView
{
    // Do not allow dismissal while still loading
    if (isUpdating) {
        return;
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view setAlpha:0];
                     }
                     completion:^(BOOL finished){
                         [self.view setHidden:YES];
                         hideCallback();
                     }
     ];
}

#pragma mark- Adding/Removing Activities

- (void) toggleActivity:(NSString *)activity forButton:(UIButton *)btn
{
    // Do nothing if we are currently updating
    if (isUpdating) {
        return;
    }
    
    if ([user.upforActivities objectForKey:activity] != nil) {
        [user.upforActivities setValue:nil forKey:activity];
        [btn setSelected:NO];
        
        // Trigger addition via HTTP
        [requestManager removeActivity:activity];
    } else {
        [user.upforActivities setObject:@"selected" forKey:activity];
        [btn setSelected:YES];
        
        // Trigger removal via HTTP
        [requestManager addActivity:activity];
    }
    
    // Trigger loading symbol
    [done setHidden:YES];
    isUpdating = YES;
    [loadingSymbol startAnimating];
}

#pragma mark- UI Button Actions

- (IBAction) done:(id)sender
{
    [self dismissView];
}

#pragma mark- Row 1

- (IBAction) toggleCoffee:(id)sender
{
    [self toggleActivity:@"coffee" forButton:sender];
}

- (IBAction)toggleFood:(id)sender
{
    [self toggleActivity:@"food" forButton:sender];    
}

- (IBAction)toggleMovies:(id)sender
{
    [self toggleActivity:@"movies" forButton:sender];
}

#pragma mark- Row 2

- (IBAction)toggleDeals:(id)sender
{
    [self toggleActivity:@"deals" forButton:sender];
}

- (IBAction)toggleDrinks:(id)sender
{
   [self toggleActivity:@"drinks" forButton:sender]; 
}

- (IBAction)toggleShopping:(id)sender
{
    [self toggleActivity:@"shopping" forButton:sender];
}

#pragma mark- Row 3

- (IBAction)toggleWalk:(id)sender
{
    [self toggleActivity:@"walk" forButton:sender];
}

- (IBAction)toggleTalking:(id)sender
{
    [self toggleActivity:@"talking" forButton:sender];
}

- (IBAction)toggleBiking:(id)sender
{
    [self toggleActivity:@"biking" forButton:sender];
}

#pragma mark- PKO Request Manager Delegate Methods

- (void) requestDidReceiveForbidden
{
    [self didUpdateStatus:nil];
}

- (void) requestDidReceiveNotFound
{
    [self didUpdateStatus:nil];
}

- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
    [self didUpdateStatus:nil];
}

- (void) didUpdateStatus:(NSDictionary *)status
{
    [loadingSymbol stopAnimating];
    isUpdating = NO;
    [done setHidden:NO];
}
@end
