//
//  changeWaitTableView.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-8.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "ChangeWaitTableView.h"

@implementation ChangeWaitTableView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        langSetting = [CVLocalizationSetting sharedInstance];
        self.transform = CGAffineTransformIdentity;
        [self setTitle:[langSetting localizedString:@"ChangeTable"]];
        
        phoneLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 70, 25)];
        phoneLable.textAlignment = NSTextAlignmentCenter;
        phoneLable.backgroundColor = [UIColor clearColor];
        phoneLable.font = [UIFont systemFontOfSize:15.0f];
        phoneLable.text = [langSetting localizedString:@"phone2:"];//手机
        [self addSubview:phoneLable];
        [phoneLable release];
        
        tableLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 70, 25)];
        tableLable.textAlignment = NSTextAlignmentCenter;
        tableLable.backgroundColor = [UIColor clearColor];
        tableLable.font = [UIFont systemFontOfSize:15.0f];
        tableLable.text = [langSetting localizedString:@"To Table:"];
        [self addSubview:tableLable];
        [tableLable release];
        
        tfPhone = [[UITextField alloc] initWithFrame:CGRectMake(95, 50, 140, 25)];
        tftable = [[UITextField alloc] initWithFrame:CGRectMake(95, 85, 140, 25)];
        
        tftable.borderStyle = UITextBorderStyleRoundedRect;
        tfPhone.borderStyle = UITextBorderStyleRoundedRect;
        
        tftable.keyboardType = UIKeyboardTypeDecimalPad;
        tfPhone.keyboardType = UIKeyboardTypeNumberPad;
        
        tfPhone.delegate = self;
        tftable.delegate = self;
        
        NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phone2"];
        tfPhone.text = phone;
        tftable.placeholder = [langSetting localizedString:@"Please enter the target ramadhin"];
        
        [self addSubview:tftable];
        [self addSubview:tfPhone];
        
        [tftable release];
        [tfPhone release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(75, 115, 40, 30);
        [btnConfirm setTitle:[langSetting localizedString:@"OK"] forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(160, 115, 40, 30);
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
    if ([tfPhone.text length]<=0 | [tftable.text length]<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Phone and table could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else if ([tfPhone.text length] != 11){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Phone error"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        if ([tftable.text length]>0)
            [dic setObject:tftable.text forKey:@"tableNumDest"];
        if ([tfPhone.text length]>0) {
            [dic setObject:tfPhone.text forKey:@"phone"];
        }
        
        [delegate ChangeWaitTableWithOptions:dic];
    }
}

- (void)cancel{
    [delegate ChangeWaitTableWithOptions:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (tfPhone == textField | tftable == textField)  //判断是否时我们想要限定的那个输入框
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
