//
//  OutOfRangeController.m
//  pekko
//
//  Created by Brandon Eum on 4/7/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "OutOfRangeMaskController.h"

@interface OutOfRangeMaskController ()

@end

@implementation OutOfRangeMaskController

@synthesize hideCallback;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setHideCallback: ^(void){}];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the view hidden and clear
    [self.view setHidden:YES];
    [self.view setAlpha:0];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Interactions

- (IBAction)touchOutsideTable:(id)sender
{
    [self hide];
}

#pragma mark - Show and Hide the View

- (void) showWithCallback:(void (^)(void))callback
{
    [self setHideCallback:callback];
    [self show];
}

- (void) show
{
    // Show the view
    [self.view setHidden:NO];
    
    // Animations - Fade In
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view setAlpha: 0.25];
    } completion:^(BOOL finished) {
        // Nothing to do
    }];
}

- (void) hide
{
    // Call the callback first because this is a mask
    hideCallback();

    [UIView animateWithDuration:0.25 animations:^{
        [self.view setAlpha:0];
    } completion:^(BOOL finished) {
        // Hide the view
        [self.view setHidden:YES];
    }];
}

@end
