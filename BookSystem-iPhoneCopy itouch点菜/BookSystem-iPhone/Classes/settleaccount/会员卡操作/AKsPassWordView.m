//
//  AKsPassWordView.m
//  BookSystem
//
//  Created by sundaoran on 13-12-4.
//
//

#import "AKsPassWordView.h"

@implementation AKsPassWordView
{
    UITextField *password;
}
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setTitle:@"密码输入"];
        
        password=[[UITextField alloc]initWithFrame:CGRectMake(100, 90, 300, 40)];
        password.borderStyle=UITextBorderStyleRoundedRect;
        password.backgroundColor=[UIColor whiteColor];
        [password becomeFirstResponder];
        password.clearButtonMode=UITextFieldViewModeAlways;
        password.placeholder=@"请输入密码";
        password.delegate=self;
        password.keyboardType=UIKeyboardTypeNumberPad;
        password.font=[UIFont systemFontOfSize:23];
        [password setSecureTextEntry:YES];
        [self addSubview:password];
        
        
        UIButton *buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSure.frame=CGRectMake(220, 265, 90, 40);
        buttonSure.titleLabel.textColor=[UIColor whiteColor];
        buttonSure.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
        [buttonSure addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonSure];
        
        UIButton *buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonCancle.titleLabel.textColor=[UIColor whiteColor];
        buttonCancle.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        buttonCancle.frame=CGRectMake(320, 265, 90, 40);
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
        [_delegate PassWordSure:password.text];
    }
    else
    {
        [_delegate PassWordSure:@""];
//        bs_dispatch_sync_on_main_thread(^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入正确的密码"
//                                                            message:nil
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"确定"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        });

    }
}
-(void)cancleButtonClick
{
    [_delegate PassWordCancle];
}


//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    
//    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
//    if([string isEqualToString:@""])
//    {
//        return YES;
//    }
//    else
//    {
//        NSString *validRegEx =@"^[0-9]+(.[0-9]{2})?$";
//        
//        NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
//        
//        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
//        
//        if (myStringMatchesRegEx)
//            
//            return YES;
//        
//        else
//            
//            return NO;
//    }
//    
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
