//
//  OutOfRangeMaskController.h
//  pekko
//
//  Created by Brandon Eum on 4/7/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PKODefinitions.h"
#import "PKOContact.h"
#import "OutOfRangeTableController.h"

@interface OutOfRangeMaskController : UIViewController
{
    NSMutableArray *outOfRangeContacts;
    PKOGenericCallback hideCallback;
}

@property (nonatomic,copy) PKOGenericCallback hideCallback;

- (IBAction) touchOutsideTable:(id)sender;

- (void) showWithCallback:(void (^)(void))callback;
- (void) show;
- (void) hide;

@end
