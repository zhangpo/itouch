//
//  AKsVipCaedChongZhiView.m
//  BookSystem
//
//  Created by sundaoran on 13-12-11.
//
//

#import "AKsVipCaedChongZhiView.h"

@implementation AKsVipCaedChongZhiView
{
    UITextField *_VipField;
}

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setTitle:@"会员卡充值"];
        
        UIButton *buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSure.frame=CGRectMake(220, 200, 80, 40);
        [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        buttonSure.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
        [buttonSure addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonSure];
        
        UIButton *buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonCancle.frame=CGRectMake(320, 200, 80, 40);
        [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        buttonCancle.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        [buttonCancle setTitle:@"取 消" forState:UIControlStateNormal];
        [buttonCancle addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonCancle];
        
        _VipField=[[UITextField alloc]init];
        _VipField.frame=CGRectMake(100, 90, 300, 40);
        _VipField.borderStyle=UITextBorderStyleRoundedRect;
        _VipField.placeholder=@"请输入充值金额";
        [self addSubview:_VipField];
        
    }
    return self;
}

-(void)sureButtonClick
{
    if([_VipField.text length]<=0)
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
        [_delegate sureVipChongZhi:_VipField.text];
    }
    
}
-(void)cancleButtonClick
{
    [_delegate cancleVipChongZhi];
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
