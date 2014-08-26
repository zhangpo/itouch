//
//  AKsBankView.m
//  BookSystem
//
//  Created by sundaoran on 13-12-3.
//
//

#import "AKsBankView.h"


@implementation AKsBankView
{
    UITextField *_bankField;
    NSString *_name;
    NSString *_money;
    int       _btnTag;
    
}

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame andName:(NSString *)name andTag:(int)btnTag andMonry:(NSString *)money
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:name];
        
        UIButton *buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSure.frame=CGRectMake(240, 265, 90, 40);
        buttonSure.titleLabel.textColor=[UIColor whiteColor];
        buttonSure.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        
        [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
        [buttonSure addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonSure];
        
        UIButton *buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonCancle.frame=CGRectMake(345, 265, 90, 40);
        buttonCancle.titleLabel.textColor=[UIColor whiteColor];
        buttonCancle.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        
        [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        [buttonCancle setTitle:@"取 消" forState:UIControlStateNormal];
        [buttonCancle addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonCancle];
        
        if([money floatValue]<=0)
        {
            _money=[NSString stringWithFormat:@"%.2f",0.0];
        }
        else
        {
            _money =money;
        }
        
        _bankField=[[UITextField alloc]init];
        _bankField.frame=CGRectMake(100, 90, 300, 40);
        _bankField.borderStyle=UITextBorderStyleRoundedRect;
        _bankField.text=_money;
        _bankField.delegate=self;
        [_bankField becomeFirstResponder];
        _bankField.clearButtonMode=UITextFieldViewModeAlways;
        _bankField.keyboardType=UIKeyboardTypeNumberPad;
        [self addSubview:_bankField];

        
        _name=name;
       _btnTag= btnTag;
        


    }
    return self;
}
-(void)cancleButtonClick
{
    [_delegate cancleBank];
}

-(void)sureButtonClick
{
    if([_bankField.text length]<=0)
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入钱数不可为空,确定重新输入"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            
        });
    }
    else
    {
        [_delegate sureBank:_bankField.text andName:_name andTag:_btnTag andMonry:_money];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
    if([string isEqualToString:@""])
    {
        return YES;
    }
    else if([string isEqualToString:@"."])
    {
        return YES;
    }
    else
    {
        NSString *validRegEx =@"^[0-9]+(.[0-9]{2})?$";
        
        NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
        
        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
        
        if (myStringMatchesRegEx)
            
            return YES;
        
        else
            
            return NO;
    }
    
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
