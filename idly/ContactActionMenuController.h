//
//  ContactActionMenuController.h
//  pekko
//
//  Created by Brandon Eum on 4/20/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PKODefinitions.h"
#import "PKOContact.h"

@protocol ContactActionMenuControllerDelegate <NSObject>

- (void) showSMSView:(PKOContact *)contact;
- (void) showPhoneView:(PKOContact *)contact;

@end

@interface ContactActionMenuController : UIViewController
{
    id delegate;
    PKOContact *_contact;
    
    __weak IBOutlet UIButton *pictureBtn;
    __weak IBOutlet UIImageView *mood;
    __weak IBOutlet UILabel *name;
    __weak IBOutlet UILabel *status;
    __weak IBOutlet UIButton *b1, *b2, *b3, *b4, *b5, *b6, *b7, *b8, *b9;
}

@property (nonatomic, strong) id delegate;

- (void) setupView;

- (void) showWithContact:(PKOContact *)contact;
- (void) hideWithCallback:(PKOGenericCallback)callback;

- (IBAction)showSMSView:(id)sender;
- (IBAction)showPhoneView:(id)sender;
@end
