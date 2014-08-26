//
//  UIViewController+UIViewController_NavButton.m
//  AiBa
//
//  Created by Wu Stan on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+UIViewController_NavButton.h"

@implementation UIViewController (UIViewController_NavButton)

- (void)navBack{
    [self.navigationController popViewControllerAnimated:YES];
    
    [SVProgressHUD dismiss];
}

-(void)addLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                       target:nil
                       action:nil];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        // Add a negative spacer on iOS >= 7.0
        negativeSpacer.width = -10;
    }else{
        negativeSpacer.width = 0;
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
    
    [self.navigationItem setLeftBarButtonItems:[NSArray
                            arrayWithObjects:negativeSpacer,
                            leftBarButtonItem,
                            nil]];
}

-(void)addRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem

{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        negativeSpacer.width = -10;
    }
    else
    {
        negativeSpacer.width = 0;
    }
    [self.navigationItem setRightBarButtonItems:[NSArray
                             arrayWithObjects:negativeSpacer,
                             rightBarButtonItem,
                             nil]];
}


- (void)addNavBack{
    UIButton *btnback = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnback setBackgroundImage:[UIImage imageNamed:@"ABNavBack.png"] forState:UIControlStateNormal];
    [btnback sizeToFit];
    

    
//    btnback.layer.cornerRadius=8;
//    btnback.layer.borderWidth=1.0f;
//    btnback.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    [btnback addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
//    btnback.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
//    [btnback addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
//    [btnback setTitle:@"返回" forState:UIControlStateNormal];
//    [btnback setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    btnback.titleLabel.font = [UIFont systemFontOfSize:14];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnback];
    [self addLeftBarButtonItem:item];
    //self.navigationItem.leftBarButtonItem = item;
    [item release];
    
    
}

- (void)addNavButtonWithTitle:(NSString *)title image:(UIImage *)img atPosition:(SWNavItemPosition)position action:(SEL)sel{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (SWNavItemPositionLeft==position)
//        self.navigationItem.leftBarButtonItem = item;
        [self addLeftBarButtonItem:item];
    else
       // self.navigationItem.rightBarButtonItem = item;
        [self addRightBarButtonItem:item];
    [item release];
}

- (void)addNavButtonWithImage:(UIImage *)img atPosition:(SWNavItemPosition)position action:(SEL)sel{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];

    
    [btn setImage:img forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    if (btn.frame.size.width<39 && btn.frame.size.height<30)
        btn.frame= CGRectMake(0, 0, 39, 30);
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (SWNavItemPositionLeft==position)
        //self.navigationItem.leftBarButtonItem = item;
        [self addLeftBarButtonItem:item];
    else
        //self.navigationItem.rightBarButtonItem = item;
        [self addRightBarButtonItem:item];
    [item release];
}

- (void)addRefreshToPosition:(SWNavItemPosition)position{
    UIButton *btnrefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnrefresh setImage:[UIImage imageNamed:@"ABNavRefresh.png"] forState:UIControlStateNormal];
    [btnrefresh sizeToFit];
    [btnrefresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnrefresh];
    if (SWNavItemPositionLeft==position)
        [self addLeftBarButtonItem:item];
//        self.navigationItem.leftBarButtonItem = item;
    else
        [self addRightBarButtonItem:item];
//        self.navigationItem.rightBarButtonItem = item;
    [item release];
}

- (void)addNavButtonWithTitle:(NSString *)title atPosition:(SWNavItemPosition)position action:(SEL)sel{
    UIButton *btnrefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *img = [UIImage imageNamed:@"BSNavButton.png"];
    UIImage *dimg = [img stretchableImageWithLeftCapWidth:24 topCapHeight:14];
    
    [btnrefresh setBackgroundImage:dimg forState:UIControlStateNormal];
    [btnrefresh setTitleColor:[UIColor colorWithRed:.69 green:0 blue:.16 alpha:1] forState:UIControlStateNormal];
    [btnrefresh setTitle:title forState:UIControlStateNormal];
    btnrefresh.titleLabel.font = [UIFont systemFontOfSize:13];
    btnrefresh.frame = title.length>0?CGRectMake(0, 0, 49+(title.length-2)*10, 29):CGRectZero;
    [btnrefresh addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btnrefresh];
    if (SWNavItemPositionLeft==position)
//        self.navigationItem.leftBarButtonItem = item;
        [self addLeftBarButtonItem:item];
    else
   //     self.navigationItem.rightBarButtonItem = item;
    [self addRightBarButtonItem:item];
    [item release];
}

- (void)addBGColor:(UIColor *)color{
    if (!color)
        color = [UIColor colorWithRed:1 green:.95 blue:.78 alpha:1];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"ABMorePatternBG.png"]];
    self.view.backgroundColor = color;
}

- (void)setNavTitle:(NSString *)str{
    UILabel *lbl = [UILabel createLabelWithFrame:CGRectZero font:[UIFont boldSystemFontOfSize:20] textColor:[UIColor whiteColor]];
    lbl.text = str;
    [lbl sizeToFit];
    self.navigationItem.titleView = lbl;
}

- (void)showFrameLog{
    NSLog(@"%@'s Frame:%@",NSStringFromClass([self class]),NSStringFromCGRect(self.view.frame));
}

- (void)addBackGesture{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeLeft];
    [swipeLeft release];
}

- (void)swiped{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addNavButtonAndTitle:(NSString *)title{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    v.backgroundColor = [UIColor colorWithRed:.75 green:.61 blue:.39 alpha:1];
    [self.view addSubview:v];
    
    UILabel *lbl = [UILabel createLabelWithFrame:v.bounds font:[UIFont boldSystemFontOfSize:22] textColor:[UIColor whiteColor]];
    lbl.textAlignment = NSTextAlignmentCenter;
    [v addSubview:lbl];
    lbl.text = title;
    lbl.userInteractionEnabled = NO;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"BSNavBack.png"] forState:UIControlStateNormal];
    [btn sizeToFit];
    [btn addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:btn];
}

- (UIViewController *)viewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    
    return (UIViewController *)next;
}
@end
