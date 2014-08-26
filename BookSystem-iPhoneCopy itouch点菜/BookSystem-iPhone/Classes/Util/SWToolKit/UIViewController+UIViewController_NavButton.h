//
//  UIViewController+UIViewController_NavButton.h
//  AiBa
//
//  Created by Wu Stan on 12-5-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SWNavItemPositionLeft,
    SWNavItemPositionRight
}SWNavItemPosition;

@interface UIViewController (UIViewController_NavButton)
- (void)navBack;

- (void)addNavBack;
- (void)addRefreshToPosition:(SWNavItemPosition)position;
- (void)addNavButtonWithTitle:(NSString *)title image:(UIImage *)img atPosition:(SWNavItemPosition)position action:(SEL)sel;
- (void)addNavButtonWithTitle:(NSString *)title atPosition:(SWNavItemPosition)position action:(SEL)sel;
- (void)addNavButtonWithImage:(UIImage *)img atPosition:(SWNavItemPosition)position action:(SEL)sel;
- (void)addBGColor:(UIColor *)color;
- (void)setNavTitle:(NSString *)str;
- (void)showFrameLog;
- (void)addBackGesture;
- (void)addNavButtonAndTitle:(NSString *)title;
//事件响应者链
- (UIViewController *)viewController;
@end
