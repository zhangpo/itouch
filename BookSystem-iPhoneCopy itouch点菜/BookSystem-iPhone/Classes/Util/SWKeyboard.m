//
//  SWKeyboard.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "SWKeyboard.h"

@implementation SWKeyboard
@synthesize delegate,tfInput;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:self.bounds];
        [imgv setImage:[UIImage imageNamed:@"padbg.png"]];
        [self addSubview:imgv];
        [imgv release];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"paddown.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"paddownsel.png"] forState:UIControlStateHighlighted];
        [btn sizeToFit];
        btn.center = CGPointMake(26, frame.size.height/2);
        [btn addTarget:self action:@selector(updownClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"padsearch.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"padsearchsel.png"] forState:UIControlStateHighlighted];
        [btn sizeToFit];
        btn.center = CGPointMake(320-26, frame.size.height/2);
        [btn addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        tfInput = [[UITextField alloc] initWithFrame:CGRectMake(50, (frame.size.height-32)/2, 213, 32)];
        tfInput.borderStyle = UITextBorderStyleRoundedRect;
        tfInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:tfInput];
        [tfInput release];
        SWInputView *iw = [[[SWInputView alloc] initWithFrame:CGRectMake(0, 0, 320, 243)] autorelease];
        iw.delegate = self;
        tfInput.inputView = iw;
        [tfInput becomeFirstResponder];
//        [tfInput resignFirstResponder];
    }
    return self;
}

- (void)updownClicked:(UIButton *)btn{
    btn.selected = !btn.selected;
    NSString *str = btn.selected?@"up":@"down";
    if (btn.selected){
        [tfInput resignFirstResponder];
    }else{
        [tfInput becomeFirstResponder];
    }
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pad%@.png",str]] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pad%@sel.png",str]] forState:UIControlStateHighlighted];
}

- (void)searchClicked:(UIButton *)btn{
    
}

#pragma mark - SWInputView Delegate
- (void)keyboardPressed:(UIButton *)btn{
    if (btn.tag<10){
        NSMutableString *str = [NSMutableString string];
        [str appendString:tfInput.text];
        [str appendString:[NSString stringWithFormat:@"%d",btn.tag]];
        tfInput.text = str;
    }else if (11==btn.tag){
        if (tfInput.text.length>0)
            tfInput.text = [tfInput.text substringToIndex:tfInput.text.length-1];
//        else
//            tfInput.text = nil;
    }
    
    if (delegate && [(NSObject *)delegate respondsToSelector:@selector(keyboardTextChanged:)])
        [delegate keyboardTextChanged:tfInput.text];
}
@end


@implementation SWInputView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 320*243
        self.backgroundColor = [UIColor whiteColor];
        for (int i=0;i<10;i++){
            int dindex = i-1;
            int row = dindex/3;
            int column = dindex%3;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pad%d.png",i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pad%dsel.png",i]] forState:UIControlStateHighlighted];
            if (0==i){
                row = 3;
                column = 1;
            }
            btn.frame = CGRectMake(5+104*column, 7+58*row, 104, 56);
            [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            btn.tag = i;
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"padstar.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"padstarsel.png"] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(5+104*0, 7+58*3, 104, 56);
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btn.tag = 10;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"paddel.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"paddelsel.png"] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(5+104*2, 7+58*3, 104, 56);
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btn.tag = 11;
    }
    return self;
}

- (void)buttonClicked:(UIButton *)btn{
    if (delegate && [(NSObject *)delegate respondsToSelector:@selector(keyboardPressed:)]){
        [delegate keyboardPressed:btn];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
