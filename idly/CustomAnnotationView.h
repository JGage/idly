//
//  CustomAnnotationView.h
//  pekko
//
//  Created by Brandon Eum on 5/15/13.
//  Copyright (c) 2013 Gage IT. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotationView : MKAnnotationView
{
    IBOutlet UIView *topLevelSubview;
    __weak IBOutlet UIImageView *_frame1;
    __weak IBOutlet UIImageView *_pic;
    __weak IBOutlet UIImageView *_mood;
}

- (void) hideFrame;
- (void) showFrame;
- (void) selectFrame;
- (UIImageView *) getPic;
- (void) setPic:(UIImage *)pic;
- (void) setMood:(UIImage *)mood;

@end
