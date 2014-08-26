//
//  BSSendView.h
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BSRotateView : UIView {
    UILabel *lblTitle;
}

- (void)setTitle:(NSString *)str;
- (void)firstAnimation;
- (void)secondAnimation;
@end
