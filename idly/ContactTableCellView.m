//
//  ContactTableCellView.m
//  pekko
//
//  Created by Brandon Eum on 3/7/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "ContactTableCellView.h"

@implementation ContactTableCellView

@synthesize name, msg, profileImg, photo, status, requested;
@synthesize b1, b2, b3, b4, b5, b6, b7, b8, b9;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ContactTableCellView" owner:self options:nil];
        [self addSubview:topLevelSubView];
        [msg setFont:[UIFont italicSystemFontOfSize:12]];
    }
    return self;
}

@end
