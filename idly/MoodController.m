//
//  MoodController.m
//  pekko
//
//  Created by Brandon Eum on 3/16/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "MoodController.h"

@implementation MoodController

@synthesize delegate;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        requestManager = [[PKORequestManager alloc] init];
        [requestManager setDelegate:self];
    }
    return self;
}

#pragma mark- View Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    CGFloat height = self.view.frame.size.height;
    CGFloat width  = self.view.frame.size.width;
    CGRect frame = CGRectMake(20, height*-1, width, height);
    self.view.frame = frame;
}

- (void) viewWillAppear:(BOOL)animated
{
    // Set the existing mood from the user container before showing the view
    [super viewWillAppear:animated];
}

#pragma mark- Show and hide the view

- (void) showView
{
    CGFloat height = self.view.frame.size.height;
    CGFloat width  = self.view.frame.size.width;
    CGRect frame = CGRectMake(20, height*-1, width, height);
    self.view.frame = frame;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = CGRectMake(20, 80, width, height);
        self.view.frame = frame;
    }];
}

- (void) hideViewWithCallback:(void (^)(void))callback
{
    CGFloat height = self.view.frame.size.height;
    CGFloat width  = self.view.frame.size.width;
    
    [UIView animateWithDuration:0.5
        animations:^{
            CGRect frame = CGRectMake(20, height*-1, width, height);
            self.view.frame = frame;
        }
        completion:^(BOOL finished) {
            callback();
            [delegate showButtons];
        }
     ];
}

// Convenience method for hiding the view without a callback
- (void) hideView
{
    [self hideViewWithCallback:^{}];
}

#pragma mark- Update user mood

- (void) updateMood:(NSString *)mood
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:mood forKey:@"status"];

    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    [requestManager updateStatus:data];
    [self hideView];
}


#pragma mark- Button Actions

- (IBAction) cancel:(id)sender
{
    [self hideView];
}


- (IBAction) setMoodToHappy:(id)sender
{
    [self updateMood:@"happy"];
}

- (IBAction) setMoodToOkay:(id)sender
{
    [self updateMood:@"okay"];
}

- (IBAction) setMoodToBored:(id)sender
{
    [self updateMood:@"bored"];
}

- (IBAction) setMoodToBlah:(id)sender
{
    [self updateMood:@"blah"];
}

- (IBAction) setMoodToSad:(id)sender
{
    [self updateMood:@"sad"];
}

- (IBAction) setMoodToAnnoyed:(id)sender
{
    [self updateMood:@"annoyed"];
}

- (IBAction) setMoodToUpset:(id)sender
{
    [self updateMood:@"upset"];
}


#pragma mark- PKOReqeustManager deleget methods

- (void) requestDidReceiveBadRequest:(NSDictionary *)response
{
    
}

- (void) requestDidReceiveForbidden
{
    
}

- (void) requestDidReceiveNotFound
{
    
}

- (void) didUpdateStatus:(NSDictionary *)status
{
    [delegate didReceiveMyStatus:status];
}

@end
