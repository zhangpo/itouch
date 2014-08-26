//
//  AKsPassWordView2.m
//  BookSystem
//
//  Created by sundaoran on 13-12-20.
//
//

#import "AKsPassWordView2.h"

@implementation AKsPassWordView2
{
    UITextField *password;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitle:@"密码输入"];
        
        password=[[UITextField alloc]initWithFrame:CGRectMake(100, 90, 300, 40)];
        password.borderStyle=UITextBorderStyleRoundedRect;
        [password becomeFirstResponder];
        password.backgroundColor=[UIColor whiteColor];
        password.clearButtonMode=UITextFieldViewModeAlways;
        password.placeholder=@"请输入密码";
        password.font=[UIFont systemFontOfSize:23];
        [password setSecureTextEntry:YES];
        [self addSubview:password];
        
        
        UIButton *buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSure.frame=CGRectMake(240, 265, 80, 40);
        buttonSure.titleLabel.textColor=[UIColor whiteColor];
        buttonSure.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
        [buttonSure addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonSure];
        
        UIButton *buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonCancle.frame=CGRectMake(345, 265, 80, 40);
        buttonCancle.titleLabel.textColor=[UIColor whiteColor];
        buttonCancle.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        [buttonCancle setTitle:@"取 消" forState:UIControlStateNormal];
        [buttonCancle addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonCancle];

    }
    return self;
}
-(void)sureButtonClick
{
    if([password.text length]!=0)
    {
        [_delegate PassWord2Sure:password.text];
    }
    else
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入正确的密码"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        });
        
    }
}
-(void)cancleButtonClick
{
    [_delegate PassWord2Cancle];
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
