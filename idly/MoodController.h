//
//  MoodController.h
//  pekko
//
//  Created by Brandon Eum on 3/16/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKORequestManager.h"

@protocol MoodControllerDelegate <NSObject,PKORequestManagerDelegate>

- (void) showButtons;

@end

@interface MoodController : UIViewController <PKORequestManagerDelegate>
{
    PKORequestManager *requestManager;
}

@property (nonatomic,weak) id<MoodControllerDelegate> delegate;

- (void) showView;
- (void) hideView;
- (void) hideViewWithCallback:(void (^)(void))callback;

- (IBAction) cancel:(id)sender;

- (void) updateMood:(NSString *)mood;

- (IBAction) setMoodToHappy:(id)sender;
- (IBAction) setMoodToOkay:(id)sender;
- (IBAction) setMoodToBored:(id)sender;
- (IBAction) setMoodToBlah:(id)sender;
- (IBAction) setMoodToSad:(id)sender;
- (IBAction) setMoodToAnnoyed:(id)sender;
- (IBAction) setMoodToUpset:(id)sender;

@end
