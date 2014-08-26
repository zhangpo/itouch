//
//  BSOpenTableView.m
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ZCOpenTableView.h"
#import "CVLocalizationSetting.h"

@implementation ZCOpenTableView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        langSetting = [CVLocalizationSetting sharedInstance];
        self.transform = CGAffineTransformIdentity;
        [self setTitle:@"开台"];
        
        lblUser = [[UILabel alloc] initWithFrame:CGRectMake(20, 45, 70, 25)];
        lblUser.textAlignment = NSTextAlignmentCenter;
        lblUser.backgroundColor = [UIColor clearColor];
        lblUser.font = [UIFont systemFontOfSize:15.0f];
        lblUser.text = @"工号:";
        [self addSubview:lblUser];
        [lblUser release];
        
        lblPeople = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 70, 25)];
        lblPeople.textAlignment = NSTextAlignmentCenter;
        lblPeople.backgroundColor = [UIColor clearColor];
        lblPeople.font = [UIFont systemFontOfSize:15.0f];
        lblPeople.text = @"人数:";
        [self addSubview:lblPeople];
        [lblPeople release];
        
        lblWaiter = [[UILabel alloc] initWithFrame:CGRectMake(20, 125, 70, 25)];
        lblWaiter.textAlignment = NSTextAlignmentCenter;
        lblWaiter.backgroundColor = [UIColor clearColor];
        lblWaiter.font = [UIFont systemFontOfSize:15.0f];
        lblWaiter.text = @"服务员号:";
        [self addSubview:lblWaiter];
        [lblWaiter release];
        
        
        
        tfUser = [[UITextField alloc] initWithFrame:CGRectMake(95, 45, 140, 25)];
        tfPeople = [[UITextField alloc] initWithFrame:CGRectMake(95, 85, 140, 25)];
        tfWaiter = [[UITextField alloc] initWithFrame:CGRectMake(95, 125, 140, 25)];
        tfUser.borderStyle = UITextBorderStyleRoundedRect;
        tfPeople.borderStyle = UITextBorderStyleRoundedRect;
        tfWaiter.borderStyle = UITextBorderStyleRoundedRect;
        
        tfWaiter.keyboardType = UIKeyboardTypeNumberPad;
        tfPeople.keyboardType = UIKeyboardTypeNumberPad;
        tfUser.keyboardType = UIKeyboardTypeNumberPad;
        
        tfPeople.delegate = self;
        tfUser.delegate = self;
        tfWaiter.delegate = self;
        
        [self addSubview:tfUser];
        [self addSubview:tfPeople];
        [self addSubview:tfWaiter];
        
        [tfUser release];
        [tfPeople release];
        [tfWaiter release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(75, 160, 40, 30);
        [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(160, 160, 40, 30);
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        tfUser.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
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
    self.delegate = nil;
    [super dealloc];
}


- (void)confirm{
    if ([tfUser.text length]<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"User could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:tfUser.text forKey:@"user"];
        
        if ([tfPeople.text length]>0)
            [dic setObject:tfPeople.text forKey:@"people"];
        if ([tfWaiter.text length]>0)
            [dic setObject:tfWaiter.text forKey:@"waiter"];
        
        [delegate openTableWithOptions:dic];
    }
}

- (void)cancel{
    [delegate openTableWithOptions:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (tfUser == textField | tfWaiter == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 10) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:10];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }
    if (tfPeople == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 2) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:2];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }
    return YES;
}
@end
