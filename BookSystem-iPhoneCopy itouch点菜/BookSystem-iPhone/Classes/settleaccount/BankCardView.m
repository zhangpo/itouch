//
//  BankCardView.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-13.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "BankCardView.h"
#import "sharedData.h"

@implementation BankCardView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame dicMoney:(NSDictionary *)dicMoney
{
    self = [super initWithFrame:frame];
    if (self) {
        dic = [[NSMutableDictionary dictionaryWithDictionary:dicMoney] retain];
        langSetting = [CVLocalizationSetting sharedInstance];
        self.transform = CGAffineTransformIdentity;
        [self setTitle:@"银行卡"];
        
        tfMoney = [[UITextField alloc] initWithFrame:CGRectMake(35, 70, 200, 25)];
        tfMoney.borderStyle = UITextBorderStyleRoundedRect;
        tfMoney.keyboardType = UIKeyboardTypeDecimalPad;
        tfMoney.placeholder = @"请输入支付现金数";
        tfMoney.delegate = self;
        [self addSubview:tfMoney];
        [tfMoney release];
        
        tfMoney.text = [[sharedData sharedInstance] yingFuMoney];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(75, 135, 40, 30);
        [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(160, 135, 40, 30);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


- (void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}


- (void)confirm{
    if ([tfMoney.text length]<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"User could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
        [dic setObject:tfMoney.text forKey:@"money"];
        [delegate BankCardWithOptions:dic];
    }
}

- (void)cancel{
    [delegate BankCardWithOptions:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (tfMoney == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 10) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:10];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }
    return YES;
}

@end
