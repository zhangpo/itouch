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
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.transform = CGAffineTransformRotate(self.transform, M_PI/3.0f);
        
        UIImage *imgBG = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cv_rotation_background" ofType:@"png"]];
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:self.bounds];
//        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 280, 250)];
        [imgv setImage:imgBG];
        [imgBG release];
        [self addSubview:imgv];
        [imgv release];
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2-60-20, 0, 120, 35)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.textColor = [UIColor darkGrayColor];
        lblTitle.font = [UIFont boldSystemFontOfSize:15.0f];
        lblTitle.textAlignment = NSTextAlignmentCenter;
        [imgv addSubview:lblTitle];
        [lblTitle release];
        
        
        
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

- (void)dealloc
{
    [super dealloc];
}


- (void)firstAnimation{    
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.3, 0.3), M_PI/6.0f);
        self.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
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
        self.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    }];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
}

- (void)setTitle:(NSString *)str{
    lblTitle.text = str;
}
@end
