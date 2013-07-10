//
//  ContactTableCellView.h
//  pekko
//
//  Created by Brandon Eum on 3/7/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableCellView : UIView
{
    IBOutlet UIView *topLevelSubView;
    __weak IBOutlet UIImageView *profileImg;
    __weak IBOutlet UIImageView *photo;
    __weak IBOutlet UIImageView *status;
    __weak IBOutlet UILabel *name;
    __weak IBOutlet UILabel *msg;
    __weak IBOutlet UILabel *requested;
    
    __weak IBOutlet UIButton *b1;
    __weak IBOutlet UIButton *b2;
    __weak IBOutlet UIButton *b3;
    __weak IBOutlet UIButton *b4;
    __weak IBOutlet UIButton *b5;
    __weak IBOutlet UIButton *b6;
    __weak IBOutlet UIButton *b7;
    __weak IBOutlet UIButton *b8;
    __weak IBOutlet UIButton *b9;
}

@property (nonatomic,weak) IBOutlet UIButton *b1, *b2, *b3, *b4, *b5, *b6, *b7, *b8, *b9;
@property (nonatomic,weak) UILabel *name, *msg, *requested;
@property (nonatomic,weak) UIImageView *profileImg, *photo, *status;

@end
