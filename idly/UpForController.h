//
//  UpForController.h
//  pekko
//
//  Created by Brandon Eum on 4/6/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PKORequestManager.h"
#import "PKOUserContainer.h"

typedef void (^HideCallback)(void);

@interface UpForController : UIViewController <PKORequestManagerDelegate>
{
    PKORequestManager *requestManager;
    PKOUserContainer *user;
    
    HideCallback hideCallback;
    
    NSArray *availableActivities;
    NSMutableDictionary *buttonDictionary;
    
    __weak IBOutlet UIButton *coffee, *food, *movies;
    __weak IBOutlet UIButton *deals, *drinks, *shopping;
    __weak IBOutlet UIButton *walk, *talking, *biking;
    
    __weak IBOutlet UIButton *done;
    
    __weak IBOutlet UIActivityIndicatorView *loadingSymbol;
    
    BOOL isUpdating;
}

// UI View controls
- (void) setImagesFromUser;
- (void) showView;
- (void) showViewWithCallback:(void (^)(void))callback;
- (void) dismissView;

// PKO Request

- (void) toggleActivity:(NSString *)activity forButton:(UIButton *)btn;


// Button targets
- (IBAction) done:(id)sender;

- (IBAction) toggleCoffee:(id)sender;
- (IBAction) toggleFood:(id)sender;
- (IBAction) toggleMovies:(id)sender;

- (IBAction) toggleDeals:(id)sender;
- (IBAction) toggleDrinks:(id)sender;
- (IBAction) toggleShopping:(id)sender;

- (IBAction) toggleWalk:(id)sender;
- (IBAction) toggleTalking:(id)sender;
- (IBAction) toggleBiking:(id)sender;

@end
