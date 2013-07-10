//
//  CustomAnnotationView.m
//  pekko
//
//  Created by Brandon Eum on 5/15/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView


- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CustomAnnotationView" owner:self options:nil];
        [self addSubview:topLevelSubview];
        CGRect frame  = self.frame;
        CGRect nf = CGRectMake(frame.origin.x - 18, frame.origin.y - 50, frame.size.width, frame.size.height);
        [self setFrame:nf];
    }
    
    return self;
}
 
/*
- (id) initWithFrame:(CGRect)frame
{
    CGRect nf = CGRectMake(frame.origin.x - 50, frame.origin.y - 50, frame.size.width, frame.size.height);
    self = [super initWithFrame:nf];
    if (self) {
        
    }
    
    return self;
}*/

- (void) hideFrame
{
    _frame1.hidden = YES;
}

- (void) showFrame
{
    _frame1.hidden = NO;
}

- (void) selectFrame
{
    // Do nothin
}

- (UIImageView *) getPic
{
    return _pic;
}

- (void) setPic:(UIImage *)pic
{
    _pic.image = pic;
}

- (void) setMood:(UIImage *)mood
{
    _mood.image = mood;
}
@end
