//
//  BSSendView.m
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSRotateView.h"


@implementation BSRotateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
//        self.transform = CGAffineTransformRotate(self.transform, M_PI/3.0f);
        
        UIImage *imgBG = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cv_rotation_background" ofType:@"png"]];
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:self.bounds];
        [imgv setImage:imgBG];
        [imgBG release];
        [self addSubview:imgv];
        [imgv release];
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 460, 42)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor darkGrayColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:24];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        [imgv addSubview:lblTitle];
        [lblTitle release];
        
        self.center = CGPointMake(384, 502);
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



- (void)firstAnimation{    
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.3, 0.3), M_PI/6.0f);
        self.center = CGPointMake(584, 804);
    } completion:^(BOOL finished) {
        if (finished)
            [self performSelector:@selector(secondAnimation)];
    }];
//    
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
}

- (void)secondAnimation{
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.0, 1.0),0);
        self.center = CGPointMake(384, 502);
    }];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
}

- (void)setTitle:(NSString *)str{
    lblTitle.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:25];
    lblTitle.textColor=[UIColor blackColor];
    lblTitle.text = str;
}
@end
