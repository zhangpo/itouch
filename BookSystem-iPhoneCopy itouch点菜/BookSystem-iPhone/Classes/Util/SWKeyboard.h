//
//  SWKeyboard.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SWKeyboardDelegate

- (void)keyboardTextChanged:(NSString *)inputText;

@end

@protocol SWInputViewDelegate

- (void)keyboardPressed:(UIButton *)btn;

@end

@interface SWKeyboard : UIView<SWInputViewDelegate>{
    UITextField *tfInput;
    
    id<SWKeyboardDelegate> delegate;
}
@property (nonatomic,assign) id<SWKeyboardDelegate> delegate;
@property (nonatomic,assign) UITextField *tfInput;
@end

@interface SWInputView : UIView{
    id<SWInputViewDelegate> delegate;
}
@property (nonatomic,assign) id<SWInputViewDelegate> delegate;
//@property (nonatomic,assign) UITextField *tfInput;
@end
