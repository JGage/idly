//
//  OutOfRangeTableController.h
//  pekko
//
//  Created by Brandon Eum on 4/7/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PKODefinitions.h"
#import "PKOContact.h"
#import "PKOUserContainer.h"
#import "PKOAnnotation.h"

#import "ContactsTableController.h"


@interface OutOfRangeTableController : UIViewController <ContactsTableControllerDelegate>
{
    id delegate;
    NSMutableArray *outOfRangeContacts;
    PKOContactCallback hideCallback;
    
    ContactsTableController *tableController;
}

@property (nonatomic,strong) id delegate;
@property (nonatomic,strong) NSMutableArray *outOfRangeContacts;
@property (nonatomic,copy) PKOContactCallback hideCallback;

- (void) showWithCallback:(void (^)(id contact))callback;
- (void) show;
- (void) hideWithContact:(PKOContact *)contact;

- (void) reloadContacts:(NSArray *)contacts;

@end
