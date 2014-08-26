//
//  WaitTableView.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-27.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "WaitTableView.h"

@implementation WaitTableView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        langSetting = [CVLocalizationSetting sharedInstance];
        self.transform = CGAffineTransformIdentity;
        [self setTitle:[langSetting localizedString:@"Wait"]];
        
        phoneLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 70, 25)];
        phoneLable.textAlignment = NSTextAlignmentCenter;
        phoneLable.backgroundColor = [UIColor clearColor];
        phoneLable.font = [UIFont systemFontOfSize:15.0f];
        phoneLable.text = [langSetting localizedString:@"phone:"];//手机
        [self addSubview:phoneLable];
        [phoneLable release];
        
        manLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 70, 25)];
        manLable.textAlignment = NSTextAlignmentCenter;
        manLable.backgroundColor = [UIColor clearColor];
        manLable.font = [UIFont systemFontOfSize:15.0f];
        manLable.text = [langSetting localizedString:@"Man"];
        [self addSubview:manLable];
        [manLable release];
        
        womanLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 70, 25)];
        womanLable.textAlignment = NSTextAlignmentCenter;
        womanLable.backgroundColor = [UIColor clearColor];
        womanLable.font = [UIFont systemFontOfSize:15.0f];
        womanLable.text = [langSetting localizedString:@"Woman"];
        [self addSubview:womanLable];
        [womanLable release];
        
        
        tfPhone = [[UITextField alloc] initWithFrame:CGRectMake(95, 50, 140, 25)];
        tfman = [[UITextField alloc] initWithFrame:CGRectMake(95, 85, 140, 25)];
        tfwoman = [[UITextField alloc] initWithFrame:CGRectMake(95, 120, 140, 25)];
        tfman.borderStyle = UITextBorderStyleRoundedRect;
        tfwoman.borderStyle = UITextBorderStyleRoundedRect;
        tfPhone.borderStyle = UITextBorderStyleRoundedRect;
        
        tfman.keyboardType = UIKeyboardTypeNumberPad;
        tfwoman.keyboardType = UIKeyboardTypeNumberPad;
        tfPhone.keyboardType = UIKeyboardTypePhonePad;
        
        tfPhone.delegate = self;
        tfwoman.delegate = self;
        tfman.delegate = self;
        
        [self addSubview:tfman];
        [self addSubview:tfwoman];
        [self addSubview:tfPhone];
        
        [tfman release];
        [tfwoman release];
        [tfPhone release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(75, 155, 40, 30);
        [btnConfirm setTitle:[langSetting localizedString:@"OK"] forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(160, 155, 40, 30);
        [btnCancel setTitle:[langSetting localizedString:@"Cancel"] forState:UIControlStateNormal];
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
    if ([tfPhone.text length]<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"phone could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else if ([tfPhone.text length] != 11){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Phone error"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else if ([tfman.text length]<=0 && [tfwoman.text length]<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"people could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        int man = [tfman.text intValue];
        int woman = [tfwoman.text intValue];
        int mAndwo = man + woman;
        if (mAndwo <= 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"number zero"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }else if (mAndwo > 99){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"The total number of not greater than 99"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else{
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            if (woman>0)
                [dic setObject:tfwoman.text forKey:@"woman"];
            if (man>0)
                [dic setObject:tfman.text forKey:@"man"];
            if ([tfPhone.text length]>0) {
                [dic setObject:tfPhone.text forKey:@"phone"];
            }
            
            [delegate waitTableWithOptions:dic];
        }
       
    }
}

- (void)cancel{
    [delegate waitTableWithOptions:nil];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (tfman == textField | tfwoman == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 2) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:2];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }else if (tfPhone == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 11) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:11];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }
    return YES;
}

@end
