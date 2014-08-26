//
//  AKsMoneyVIew.m
//  BookSystem
//
//  Created by sundaoran on 13-12-3.
//
//

#import "AKsMoneyVIew.h"
#import "AKsNetAccessClass.h"

@implementation AKsMoneyVIew
{
    UITextField *_moneyField;
    NSString    *_name;
    int         _btnTag;
}

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame andName:(NSString *)name andTag:(int )btnTag
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
        
        _moneyField=[[UITextField alloc]init];
        _moneyField.delegate=self;
        [_moneyField becomeFirstResponder];
        _moneyField.frame=CGRectMake(100, 90, 300, 40);
        _moneyField.borderStyle=UITextBorderStyleRoundedRect;
        _moneyField.placeholder=@"请输入支付现金数";
        _moneyField.clearButtonMode=UITextFieldViewModeAlways;
        _moneyField.keyboardType=UIKeyboardTypeNumberPad;
        [self addSubview:_moneyField];
        
        
        AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
        
        if([name isEqualToString:@"五十元"])
        {
            _moneyField.text=@"50.00";
        }
        else if(([name isEqualToString:@"一百元"]))
        {
            _moneyField.text=@"100.00";
        }
        else if([name isEqualToString:@"无需找零"])
        {
            if([netAccess.yingfuMoney floatValue]<0)
            {
                netAccess.yingfuMoney=[NSString stringWithFormat:@"%.2f",0.0];
            }
            _moneyField.text=[NSString stringWithFormat:@"%@",netAccess.yingfuMoney];
        }
        else
        {
            
        }
        
        _name=name;
        _btnTag=btnTag;
        
    }
    return self;
}
-(void)cancleButtonClick
{
    [_delegate cancleMoney];
}

-(void)sureButtonClick
{
    if([_moneyField.text length]<=0)
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
        [_delegate sureMoney:_moneyField.text andName:_name andTag:_btnTag];
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
