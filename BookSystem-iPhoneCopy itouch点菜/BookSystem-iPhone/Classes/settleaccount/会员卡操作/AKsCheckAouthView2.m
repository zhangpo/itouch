//
//  AKsCheckAouthView2.m
//  BookSystem
//
//  Created by sundaoran on 14-1-14.
//
//

#import "AKsCheckAouthView2.h"

@implementation AKsCheckAouthView2
{
    UITextField *userName;
    UITextField *userPass;
    CardJuanClass *_cardMessage;
}

- (id)initWithFrame:(CGRect)frame andCardMessage:(CardJuanClass *)cardMessage
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitle:@"授权验证"];
        _cardMessage=cardMessage;
        [self creatView];
        
    }
    return self;
}

-(void)creatView
{
    userName=[[UITextField alloc]initWithFrame:CGRectMake(100, 70, 300, 40)];
    userName.borderStyle=UITextBorderStyleRoundedRect;
    userName.backgroundColor=[UIColor whiteColor];
    userName.clearButtonMode=UITextFieldViewModeAlways;
    userName.placeholder=@"请输入授权用户名";
    userName.keyboardType=UIKeyboardTypeNumberPad;
    userName.font=[UIFont systemFontOfSize:23];
    [self addSubview:userName];
    
    userPass=[[UITextField alloc]initWithFrame:CGRectMake(100, 130, 300, 40)];
    userPass.borderStyle=UITextBorderStyleRoundedRect;
    userPass.backgroundColor=[UIColor whiteColor];
    userPass.clearButtonMode=UITextFieldViewModeAlways;
    userPass.placeholder=@"请输入授权密码";
    userPass.keyboardType=UIKeyboardTypeNumberPad;
    userPass.font=[UIFont systemFontOfSize:23];
    [self addSubview:userPass];
    
    userName.delegate=self;
    userPass.delegate=self;
    
    UIButton *buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonSure.frame=CGRectMake(220, 200, 80, 40);
    [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    
    [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
    [buttonSure addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonSure];
    
    UIButton *buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonCancle.frame=CGRectMake(320, 200, 80, 40);
    [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonCancle setTitle:@"取 消" forState:UIControlStateNormal];
    [buttonCancle addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonCancle];
    
}

-(void)sureButtonClick
{
    [_delegate sureAKsCheckAouthView:_cardMessage andUserName:userName.text andUserPass:userPass.text];
}
-(void)cancleButtonClick
{
    [_delegate cancleAKsCheckAouthView];
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
