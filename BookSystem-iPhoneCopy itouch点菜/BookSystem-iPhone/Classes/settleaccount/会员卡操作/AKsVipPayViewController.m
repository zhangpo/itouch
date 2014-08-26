//
//  AKsVipPayViewController.m
//  BookSystem
//
//  Created by sundaoran on 13-12-5.
//
//

#import "AKsVipPayViewController.h"
//#import "MBProgressHUD.h"
#import "CardJuanClass.h"
#import "AKDataQueryClass.h"
#import "AKsKvoPrice.h"
#import "AKURLString.h"
#import "AKDataQueryClass.h"
#import "AKsUserPaymentClass.h"
#import "AKsIsVipShowView.h"


@interface AKsVipPayViewController ()

@end

@implementation AKsVipPayViewController
{
    UILabel             *lblYuKe;
    UILabel             *lblYuXiao;
    UILabel             *lblJiKe;
    UILabel             *lblJiXiao;
    UILabel             *lblXianJin;
    UILabel             *lblmoney;
    
    UILabel             *_tfYuKe;
    UILabel             *_tfJiKe;
    
    UITextField         *_tfYuXiao;
    UITextField         *_tfJiXiao;
    UITextField         *_tfXianJin;
    
    UIButton            *buttonBack;
    UIButton            *buttonSure;
    
    UIView              *_showCardView;
    
    NSMutableArray      *_dataButtonArray;
    NSMutableArray      *_caozuoButtonArray;
    MBProgressHUD       *_HUD;
    AKsVipCaedChongZhiView *_chongzhi;
    AKsPassWordView     *_passWordView;
    AKsPassWordView2    *_passWordView2;
    AKsCheckAouthView2  *_checkView;
    NSArray             *_JuanMessageArray;
    
    float               _yingfuPrice;
    
    NSMutableArray      *_xiaofeiArray;
    NSMutableArray      *_FenXiaoFeiArray;
    NSMutableArray      *_youhuiHuChiArray;
    UIScrollView        *scroll;
    AKsKvoPrice         *_kvoPrice;
    
    AKDataQueryClass    *queryDataFromSql;
    CardJuanClass       *_cardMessage;
    CardJuanClass       *_cardMessagelinshi;
    
    BOOL                isJuanXiaofei;
    
    float               chuzhixiaofei;
    float               fapiaoPrice;
    float               zhaolingPrice;
    
    int                 cishu;
    AKsIsVipShowView    *showVip;
    
    //    NSString            *_chongzhiLiuShuiHao;
    //    _chongzhiLiuShuiHao=@"";
}
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}


-(id)initWithArray:(NSMutableArray *)array
{
    if(self=[super init])
    {
        //        CardJuanClass *card=[[CardJuanClass alloc]init];
        //        card.JuanId=@"1001";
        //        card.JuanMoney=@"1";
        //        card.JuanName=@"一百";
        //        card.JuanNum=@"10";
        //
        //        CardJuanClass *card2=[[CardJuanClass alloc]init];
        //        card2.JuanId=@"2002";
        //        card2.JuanMoney=@"2";
        //        card2.JuanName=@"二百";
        //        card2.JuanNum=@"20";
        //
        //        CardJuanClass *card3=[[CardJuanClass alloc]init];
        //        card3.JuanId=@"3003";
        //        card3.JuanMoney=@"3";
        //        card3.JuanName=@"三百";
        //        card3.JuanNum=@"30";
        //
        //        _JuanMessageArray=[[NSArray alloc]initWithObjects:card,card2,card3 ,nil];
        
        _JuanMessageArray=[[NSArray alloc]initWithArray:array];
    }
    return self;
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSNotificationCardFenPay object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSNotificationCardJuanPay object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSNotificationCardPayCancle object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSNotificationCardXianJinPay object:nil];
}

static int count;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AKMySegmentAndView *akv=[[AKMySegmentAndView alloc]init];
    akv.frame=CGRectMake(0, 0, 768, 44);
//    for (int i=2; i<[akv.subviews count]+1; i++)
//    {
//        [[akv.subviews lastObject]removeFromSuperview];
//        i=2;
//    }
    akv.delegate=self;
    [[akv.subviews objectAtIndex:1]removeFromSuperview];
    akv.frame=CGRectMake(0, 0, 768, 114-60);
    [self.view addSubview:akv];

    isJuanXiaofei=NO;
    count=1;
    cishu=0;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor colorWithRed:193/255.0f green:193/255.0f blue:193/255.0f alpha:1];
    
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    
    _HUD=[[MBProgressHUD alloc]initWithView:self.view];
    _HUD.dimBackground=YES;
    _HUD.labelText=@"数据加载中...";
    [_HUD show:YES];
    
    _yingfuPrice=[netAccess.yingfuMoney floatValue];
/*
    不显示自定义的segment
    UILabel *tableNumber=[[UILabel alloc]initWithFrame:CGRectMake(17,124-60, 200, 50)];
    tableNumber.textAlignment=NSTextAlignmentCenter;
    tableNumber.text=[NSString stringWithFormat:@"桌台号：%@号",netAccess.TableNum];
    tableNumber.backgroundColor=[UIColor clearColor];
    tableNumber.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:tableNumber];
    
    UILabel *saleNum=[[UILabel alloc]initWithFrame:CGRectMake(234,124-60, 300, 50)];
    saleNum.textAlignment=NSTextAlignmentCenter;
    saleNum.text=[NSString stringWithFormat:@"账单号：%@",netAccess.zhangdanId];
    saleNum.backgroundColor=[UIColor clearColor];
    saleNum.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:saleNum];
    
    UILabel *peopleNum=[[UILabel alloc]initWithFrame:CGRectMake(551,124-60, 200, 50)];
    peopleNum.textAlignment=NSTextAlignmentCenter;
    peopleNum.text=[NSString stringWithFormat:@"人数：%d人",[netAccess.PeopleWomanNum intValue]+[netAccess.PeopleManNum intValue]];
    peopleNum.backgroundColor=[UIColor clearColor];
    peopleNum.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:peopleNum];
 
 */
    
    lblmoney=[[UILabel alloc]initWithFrame:CGRectMake(17,174-60-30, 250, 50)];
    lblmoney.textAlignment=NSTextAlignmentCenter;
    lblmoney.text=[NSString stringWithFormat:@"应付金额：%@元",netAccess.yingfuMoney];
    lblmoney.backgroundColor=[UIColor clearColor];
    lblmoney.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:lblmoney];
    
    lblYuKe=[[UILabel alloc]initWithFrame:CGRectMake(20,54+170-60, 130, 50)];
    lblYuKe.textAlignment=NSTextAlignmentLeft;
    lblYuKe.text=@"储值可用余额:";
    lblYuKe.backgroundColor=[UIColor clearColor];
    lblYuKe.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:lblYuKe];
    
    lblYuXiao=[[UILabel alloc]initWithFrame:CGRectMake(400,54+170-60, 130, 50)];
    lblYuXiao.textAlignment=NSTextAlignmentLeft;
    lblYuXiao.text=@"余额消费:";
    lblYuXiao.backgroundColor=[UIColor clearColor];
    lblYuXiao.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:lblYuXiao];
    
    lblJiKe=[[UILabel alloc]initWithFrame:CGRectMake(20,124+170-60, 130, 50)];
    lblJiKe.textAlignment=NSTextAlignmentLeft;
    lblJiKe.text=@"积分可用余额:";
    lblJiKe.backgroundColor=[UIColor clearColor];
    lblJiKe.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:lblJiKe];
    
    lblJiXiao=[[UILabel alloc]initWithFrame:CGRectMake(400,124+170-60, 210, 50)];
    lblJiXiao.textAlignment=NSTextAlignmentLeft;
    lblJiXiao.text=@"积分消费:";
    lblJiXiao.backgroundColor=[UIColor clearColor];
    lblJiXiao.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:lblJiXiao];
    
    lblXianJin=[[UILabel alloc]initWithFrame:CGRectMake(20,194+170-60, 210, 50)];
    lblXianJin.textAlignment=NSTextAlignmentLeft;
    lblXianJin.text=@"现金消费:";
    lblXianJin.backgroundColor=[UIColor clearColor];
    lblXianJin.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:lblXianJin];
    
    
    _tfYuKe=[[UILabel alloc]initWithFrame:CGRectMake(150,54+170-60, 210, 50)];
    _tfYuKe.textAlignment=NSTextAlignmentRight;
    _tfYuKe.text=[NSString stringWithFormat:@"%@",netAccess.ChuZhiKeYongMoney];
    _tfYuKe.layer.cornerRadius=5;
    _tfYuKe.backgroundColor=[UIColor whiteColor];
    _tfYuKe.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:_tfYuKe];
    
    _tfJiKe=[[UILabel alloc]initWithFrame:CGRectMake(150,124+170-60, 210, 50)];
    _tfJiKe.textAlignment=NSTextAlignmentRight;
    _tfJiKe.text=[NSString stringWithFormat:@"%@",netAccess.JiFenKeYongMoney];
    _tfJiKe.layer.cornerRadius=5;
    _tfJiKe.backgroundColor=[UIColor whiteColor];
    _tfJiKe.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:_tfJiKe];
    
    _tfYuXiao=[[UITextField alloc]initWithFrame:CGRectMake(540,54+170-60, 210, 50)];
    _tfYuXiao.borderStyle=UITextBorderStyleRoundedRect;
    _tfYuXiao.backgroundColor=[UIColor whiteColor];
    _tfYuXiao.text=[NSString stringWithFormat:@"%.2f",0.00];
    _tfYuXiao.clearButtonMode=UITextFieldViewModeAlways;
    _tfYuXiao.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    _tfYuXiao.delegate=self;
    _tfYuXiao.keyboardType=UIKeyboardTypeNumberPad;
    [self.view addSubview:_tfYuXiao];
    
    
    _tfJiXiao=[[UITextField alloc]initWithFrame:CGRectMake(540,124+170-60, 210, 50)];
    _tfJiXiao.borderStyle=UITextBorderStyleRoundedRect;
    _tfJiXiao.backgroundColor=[UIColor whiteColor];
    _tfJiXiao.clearButtonMode=UITextFieldViewModeAlways;
    _tfJiXiao.text=[NSString stringWithFormat:@"%.2f",0.00];
    _tfJiXiao.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    _tfJiXiao.delegate=self;
    _tfJiXiao.keyboardType=UIKeyboardTypeNumberPad;
    [self.view addSubview:_tfJiXiao];
    
    _tfXianJin=[[UITextField alloc]initWithFrame:CGRectMake(150, 194+170-60, 598, 50)];
    _tfXianJin.borderStyle=UITextBorderStyleRoundedRect;
    _tfXianJin.backgroundColor=[UIColor whiteColor];
    _tfXianJin.clearButtonMode=UITextFieldViewModeAlways;
    _tfXianJin.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    _tfXianJin.text=[NSString stringWithFormat:@"%.2f",0.00];
    _tfXianJin.delegate=self;
    _tfXianJin.keyboardType=UIKeyboardTypeNumberPad;
    [self.view addSubview:_tfXianJin];
    
    
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(0,260+170-60, 768,40)];
    title.textAlignment=NSTextAlignmentCenter;
    title.text=@"优惠劵";
    title.layer.cornerRadius=5;
    title.backgroundColor=[UIColor clearColor];
    title.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [self.view addSubview:title];
    
    scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 728, 220)];
    scroll.backgroundColor=[UIColor colorWithRed:254/255.0f green:254/255.0f blue:254/255.0f alpha:1];
    
    
    _showCardView=[[UIView alloc]initWithFrame:CGRectMake(20,480-60,728, 370)];
    _showCardView.backgroundColor=[UIColor colorWithRed:193/255.0f green:193/255.0f blue:193/255.0f alpha:1];
    
    [self.view addSubview:_showCardView];
    
    [_showCardView addSubview:scroll];
    
    _dataButtonArray=[[NSMutableArray alloc]init];
    _caozuoButtonArray=[[NSMutableArray alloc]init];
    
    [self addJuanButton];
    
    NSArray *array2=[[NSArray alloc]initWithObjects:@"计算余额",@"计算积分",@"计算现金", nil];
    for (int i=0; i<[array2 count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateHighlighted];
        button.titleLabel.font=[UIFont systemFontOfSize:20];
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        [button setTitle:[NSString stringWithFormat:@"%@",[array2 objectAtIndex:i]] forState:UIControlStateNormal];
        button.tag=200+i;
        [button addTarget:self action:@selector(ButtonClick2:) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(10+i%3*160,i/3*75+230, 140, 65);
        [_caozuoButtonArray addObject:button];
        [_showCardView addSubview:button];
    }
    
    buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonBack setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    buttonBack.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    buttonBack.titleLabel.textAlignment=UITextAlignmentCenter;
    buttonBack.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
    [buttonBack setTitle:@"返回" forState:UIControlStateNormal];
    buttonBack.tag=203;
    [buttonBack addTarget:self action:@selector(ButtonClick2:) forControlEvents:UIControlEventTouchUpInside];
    buttonBack.frame=CGRectMake(650, 740, 80, 40);
    [self.view addSubview:buttonBack];
    
    buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    buttonSure.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    buttonSure.titleLabel.textAlignment=UITextAlignmentCenter;
    buttonSure.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
    [buttonSure setTitle:@"确认支付" forState:UIControlStateNormal];
    buttonSure.tag=204;
    [buttonSure addTarget:self action:@selector(ButtonClick2:) forControlEvents:UIControlEventTouchUpInside];
    buttonSure.frame=CGRectMake(550, 740, 80, 40);
    [self.view addSubview:buttonSure];
    
    
    
    
    _xiaofeiArray=[[NSMutableArray alloc]init];
    _FenXiaoFeiArray=[[NSMutableArray alloc]init];
    _youhuiHuChiArray=[[NSMutableArray alloc]init];
    
    _kvoPrice=[[AKsKvoPrice alloc]init];
    
    [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",_yingfuPrice] forKey:@"price"];
    [_kvoPrice addObserver:self forKeyPath:@"price" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    queryDataFromSql=[AKDataQueryClass sharedAKDataQueryClass];
    netAccess.xiaofeiliuShui=@"";
    fapiaoPrice=0;
    
    _cardMessagelinshi=[[CardJuanClass alloc]init];
    
    UIControl *control=[[UIControl alloc]initWithFrame:self.view.bounds];
    [control addTarget:self action:@selector(controlClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:control];
    [self.view sendSubviewToBack:control];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
}
-(void)controlClick
{
    [_tfJiXiao resignFirstResponder];
    [_tfYuXiao resignFirstResponder];
    [_tfXianJin resignFirstResponder];
}

//键盘显示
-(void)keyboardWillShow
{
    [UIView animateWithDuration:0.18 animations:^{
        scroll.frame=CGRectMake(0, 0, 728, 220-100);
        _showCardView.frame=CGRectMake(20,480-60,728, 370);
        buttonBack.frame=CGRectMake(650, 640, 80, 40);
        buttonSure.frame=CGRectMake(550, 640, 80, 40);
        for(UIButton *button in _caozuoButtonArray)
        {
            button.frame=CGRectMake(button.frame.origin.x, button.frame.origin.y-100, button.frame.size.width, button.frame.size.height);
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

//键盘隐藏
-(void)keyboardWillHide
{
    [UIView animateWithDuration:0.18 animations:^{
        
        scroll.frame=CGRectMake(0, 0, 728, 220);
        _showCardView.frame=CGRectMake(20,480-60,728, 470);
        buttonBack.frame=CGRectMake(650, 740, 80, 40);
        buttonSure.frame=CGRectMake(550, 740, 80, 40);
        for(UIButton *button in _caozuoButtonArray)
        {
            button.frame=CGRectMake(button.frame.origin.x, button.frame.origin.y+100, button.frame.size.width, button.frame.size.height);
        }
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(_yingfuPrice<0)
    {
        [AKsNetAccessClass sharedNetAccess].zhaolingPrice=[NSString stringWithFormat:@"%.2f",0-_yingfuPrice+chuzhixiaofei];
        lblmoney.text=[NSString stringWithFormat:@"应付金额：%.2f元",0.0];
    }
    else
    {
        lblmoney.text=[NSString stringWithFormat:@"应付金额：%.2f元",_yingfuPrice];
    }
    
    if([keyPath isEqualToString:@"price"])
    {
        if([[change valueForKey:@"new"]floatValue]<=[@"0" floatValue])
        {
            [self payFinish];
        }
    }
}

//结算完成方法
-(void)payFinish
{
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    [self.view addSubview:_HUD];
    NSArray *array= [[NSArray alloc]initWithArray:[queryDataFromSql selectDataFromSqlite:@"SELECT *FROM settlementoperate WHERE OPERATEGROUPID='6'" andApi:@"找零显示"]];
    
    NSMutableArray *PayArray= [[NSMutableArray alloc]initWithArray:[self userPaymenypinjie:[AKsNetAccessClass sharedNetAccess].userPaymentArray]];
    
    if([PayArray count])
    {
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId",[[PayArray objectAtIndex:3]stringByAppendingString:[NSString stringWithFormat:@"!%@",[array lastObject]]],@"paymentId",[[PayArray objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"!%@",[NSString stringWithFormat:@"%.2f",zhaolingPrice]]],@"paymentCnt",[[PayArray objectAtIndex:1]stringByAppendingString:[NSString stringWithFormat:@"!%@",[NSString stringWithFormat:@"%@",netAccess.molingPrice]]],@"mpaymentMoney",[[PayArray objectAtIndex:4]stringByAppendingString:@"!1"],@"payFinish",netAccess.IntegralOverall,@"integralOverall",netAccess.VipCardNum, @"cardNumber", nil];
        
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"userPayment"]] andPost:dict andTag:userPayment];
        NSLog(@"%@",dict);
    }
    else
    {
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId",[array lastObject],@"paymentId",[NSString stringWithFormat:@"%.2f",zhaolingPrice],@"paymentCnt",[NSString stringWithFormat:@"%@",netAccess.molingPrice],@"mpaymentMoney",@"1",@"payFinish",netAccess.IntegralOverall,@"integralOverall",netAccess.VipCardNum, @"cardNumber", nil];
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"userPayment"]] andPost:dict andTag:userPayment];
        NSLog(@"%@",dict);
    }
    
}
//支付拼接
-(NSMutableArray *)userPaymenypinjie:(NSMutableArray *)array
{
    NSMutableArray *MuatbleArray;
    if([array count])
    {
        AKsUserPaymentClass *userPay=((AKsUserPaymentClass *)[array objectAtIndex:0]);
        NSString *userCount=userPay.userpaymentCount;
        NSString *userMoney=userPay.userpaymentMoney;
        NSString *userTag=userPay.userpaymentTag;
        NSString *userName=userPay.userpaymentName;
        NSString *payFinish=@"0";
        for(int i=1;i<[array count];i++)
        {
            AKsUserPaymentClass *userPayValues=((AKsUserPaymentClass *)[array objectAtIndex:i]);
            userCount=[userCount stringByAppendingString:[NSString stringWithFormat:@"!%@",userPayValues.userpaymentCount]];
            userMoney=[userMoney stringByAppendingString:[NSString stringWithFormat:@"!%@",userPayValues.userpaymentMoney]];
            userName=[userName stringByAppendingString:[NSString stringWithFormat:@"!%@",userPayValues.userpaymentName]];
            userTag=[userTag stringByAppendingString:[NSString stringWithFormat:@"!%@",userPayValues.userpaymentTag]];
            payFinish=[payFinish stringByAppendingString:@"!0"];
        }
        MuatbleArray=[[NSMutableArray alloc]initWithObjects:userCount,userMoney,userName,userTag,payFinish, nil];
    }
    else
    {
        MuatbleArray=[[NSMutableArray alloc]init];
    }
    
    return MuatbleArray;
}

-(void)addJuanButton
{
    
    for (int i=0; i<[_JuanMessageArray count]; i++)
    {
        NSString *str=[NSString stringWithFormat:@"%@|%@|",((CardJuanClass *)[_JuanMessageArray objectAtIndex:i]).JuanName,((CardJuanClass *)[_JuanMessageArray objectAtIndex:i]).JuanNum];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
        button.titleLabel.font=[UIFont systemFontOfSize:20];
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        [button setTitle:[NSString stringWithFormat:@"%@",str] forState:UIControlStateNormal];
        button.tag=[((CardJuanClass *)[_JuanMessageArray objectAtIndex:i]).JuanId intValue];
        [button addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(10+(i%4)*180,10+(i/4)*100, 170, 90);
        [scroll addSubview:button];
        [_dataButtonArray addObject:button];
    }
    
    int line;
    if([_JuanMessageArray count]%4==0)
    {
        line =[_JuanMessageArray count]/4;
    }
    else
    {
        line=[_JuanMessageArray count]/4+1;
    }
    scroll.contentSize=CGSizeMake(728, line*100);
}

-(void)ButtonClick:(UIButton *)btn
{
    [_tfJiXiao resignFirstResponder];
    [_tfYuXiao resignFirstResponder];
    [_tfXianJin resignFirstResponder];
    int  index=0;
    for (UIButton *button in _dataButtonArray)
    {
        NSLog(@"%d",button.tag);
        NSLog(@"%d",btn.tag);
        
        if(button.tag!=btn.tag)
        {
            index++;
        }
        else
        {
            break;
        }
    }
    NSLog(@"%d",index);
    if(!([((CardJuanClass*)[_JuanMessageArray objectAtIndex:index]).JuanNum intValue]<count))
    {
        BOOL isHuChi=[self isYouHuiHuChi:_youhuiHuChiArray andcardMessage:[_JuanMessageArray objectAtIndex:index]];
        if(_yingfuPrice >0)
        {
            if(isHuChi)
            {
                if(!_checkView )
                {
                    [self dismissViews];
                    _checkView=[[AKsCheckAouthView2 alloc]initWithFrame:CGRectMake(0, 0, 493, 354) andCardMessage:[_JuanMessageArray objectAtIndex:index]];
                    
                    [self.view addSubview:_checkView];
                    _checkView.delegate=self;
                }
                else
                {
                    [_checkView removeFromSuperview];
                    _checkView=nil;
                }
                //
            }
            else
            {
                [NSThread detachNewThreadSelector:@selector(changbuttonThread:) toTarget:self withObject:[_JuanMessageArray objectAtIndex:index]];
            }
            
        }
        else
        {
            [self showAlter:@"结算已完成"];
        }
    }
    else
    {
        [self showAlter:@"劵张数不足"];
    }
}

-(void)sureAKsCheckAouthView:(CardJuanClass *)cardMessage andUserName:(NSString *)name andUserPass:(NSString *)pass
{
    _cardMessage=[[CardJuanClass alloc]init];
    _cardMessage=cardMessage;
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [self.view addSubview:_HUD];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",name,@"userCode",pass,@"userPass", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"checkAuth"]] andPost:dict andTag:checkAuth];
}

-(void)HHTcheckAuthSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *array=[self getArrayWithDict:dict andFunction:checkAuthName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        [self dismissViews];
        [NSThread detachNewThreadSelector:@selector(changbuttonThread:) toTarget:self withObject:_cardMessage];
        
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
}

-(void)cancleAKsCheckAouthView
{
    [_checkView removeFromSuperview];
    _checkView=nil;
}

-(void)changbuttonThread:(CardJuanClass *)JuanMessage
{
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [self.view addSubview:_HUD];
    count=1;
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId",[NSString stringWithFormat:@"%@",JuanMessage.JuanId],@"counpId",[NSString stringWithFormat:@"%d",count],@"counpCnt",[NSString stringWithFormat:@"%@",netAccess.yingfuMoney],@"counpMoney", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"userCounp"]] andPost:dict andTag:userCounp];
}

//判断是否存在优惠互斥
-(BOOL)isYouHuiHuChi:(NSMutableArray *)array andcardMessage:(CardJuanClass *)cardMessage
{
    BOOL isHuChi;
    int count=0;
    if([array count]==0)
    {
        //        [_youhuiHuChiArray addObject:cardMessage];
        _cardMessagelinshi=cardMessage;
        return NO;
    }
    
    for (int i=0; i<[array count]; i++)
    {
        NSLog(@"%@====>",cardMessage.JuanId);
        NSLog(@"%@---->",((CardJuanClass *)[array objectAtIndex:i]).JuanId);
        if([cardMessage.JuanId isEqualToString:((CardJuanClass *)[array objectAtIndex:i]).JuanId])
        {
            isHuChi=NO;
            break;
        }
        else
        {
            count++;
        }
    }
    if(count==[array count])
    {
        isHuChi=YES;
    }
    
    NSLog(@"%d",count);
    return isHuChi;
}


//会员卡劵消费
-(void)HHTuserCounpSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    [self dismissView];
    NSArray *array=[self getArrayWithDict:dict andFunction:userCounpName];
    NSLog(@"%@",array);
    if([array count]!=1)
    {
        if([[array objectAtIndex:0]isEqualToString:@"0"])
        {
            if([_youhuiHuChiArray count]==0)
            {
                [_youhuiHuChiArray addObject:_cardMessagelinshi];
            }
            if(_cardMessage)
            {
                [_youhuiHuChiArray addObject:_cardMessage];
            }
            CardJuanClass *juanMessage=[[CardJuanClass alloc]init];
            juanMessage.JuanId=[array objectAtIndex:2];
            if([[array objectAtIndex:3]isEqualToString:@""])
            {
                juanMessage.JuanName=[[AKsNetAccessClass sharedNetAccess].CardJuanDict objectForKey:juanMessage.JuanId];
            }
            else
            {
                juanMessage.JuanName=[array objectAtIndex:3];
            }
            juanMessage.JuanNum=[array objectAtIndex:4];
            juanMessage.JuanMoney=[array objectAtIndex:5];
            
            for (int i=0; i<[_dataButtonArray count]; i++)
            {
                UIButton *button=((UIButton *)[_dataButtonArray objectAtIndex:i]);
                if(button.tag==[juanMessage.JuanId intValue])
                {
                    NSArray *array=[button.titleLabel.text componentsSeparatedByString:@"|"];
                    int Juan_count=[[array objectAtIndex:1] intValue];
                    if (Juan_count>=1)
                    {
                        Juan_count--;
                    }
                    else
                    {
                        Juan_count=0;
                    }
                    NSString *name=[NSString stringWithFormat:@"%@|%d|",[array objectAtIndex:0],Juan_count];
                    [button setTitle:[NSString stringWithFormat:@"%@",name] forState:UIControlStateNormal];
                }
            }
            AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
            youhui.youMoney=juanMessage.JuanMoney;
            youhui.youName=juanMessage.JuanName;
            [_FenXiaoFeiArray addObject:youhui];
            
            _yingfuPrice-=[[array objectAtIndex:5] floatValue];
            
            if(_yingfuPrice<0)
            {
                _yingfuPrice=0;
            }
            lblmoney.text=[NSString stringWithFormat:@"应付金额：%.2f元",_yingfuPrice];
            [_xiaofeiArray addObject:juanMessage];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCardJuanPay object:youhui];
            
            [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",_yingfuPrice] forKey:@"price"];
            isJuanXiaofei=YES;
            AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
            netAccess.shiyongVipJuan=YES;
        }
        else
        {
            [self showAlter:[array lastObject]];
        }
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
}


-(void)ButtonClick2:(UIButton *)btn
{
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    
    if(200==btn.tag)
    {
        
        //        @"计算余额"
        _tfYuXiao.text=[NSString stringWithFormat:@"%.2f",_yingfuPrice-[_tfJiXiao.text doubleValue]-[_tfXianJin.text doubleValue]];
        
        _tfYuKe.text=[NSString stringWithFormat:@"%.2f",[netAccess.ChuZhiKeYongMoney doubleValue]-[_tfYuXiao.text doubleValue]];
        _tfJiKe.text=[NSString stringWithFormat:@"%.2f",[netAccess.JiFenKeYongMoney doubleValue]-[_tfJiXiao.text doubleValue]];
    }
    else if(201==btn.tag)
    {
        
        //        @"计算积分"
        _tfJiXiao.text=[NSString stringWithFormat:@"%.2f",_yingfuPrice-[_tfYuXiao.text doubleValue]-[_tfXianJin.text doubleValue]];
        
        _tfYuKe.text=[NSString stringWithFormat:@"%.2f",[netAccess.ChuZhiKeYongMoney doubleValue]-[_tfYuXiao.text doubleValue]];
        _tfJiKe.text=[NSString stringWithFormat:@"%.2f",[netAccess.JiFenKeYongMoney doubleValue]-[_tfJiXiao.text doubleValue]];
        
    }
    else if(202==btn.tag)
    {
        
        //         @"计算现金"
        _tfXianJin.text=[NSString stringWithFormat:@"%.2f",_yingfuPrice-[_tfYuXiao.text doubleValue]-[_tfJiXiao.text doubleValue]];
        
        _tfYuKe.text=[NSString stringWithFormat:@"%.2f",[netAccess.ChuZhiKeYongMoney doubleValue]-[_tfYuXiao.text doubleValue]];
        _tfJiKe.text=[NSString stringWithFormat:@"%.2f",[netAccess.JiFenKeYongMoney doubleValue]-[_tfJiXiao.text doubleValue]];
        
    }
    else if(203==btn.tag)
    {
        if(isJuanXiaofei)
        {
            [self.view addSubview:_HUD];
            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId", nil];
            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"cancleUserCounp"]] andPost:dict andTag:cancleUserCounp];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (204==btn.tag)
    {
        if((([_tfJiXiao.text doubleValue]+[_tfYuXiao.text doubleValue])<=_yingfuPrice) && ([_tfYuXiao.text doubleValue]<=[netAccess.ChuZhiKeYongMoney doubleValue]) && ([_tfJiXiao.text doubleValue]<=[netAccess.JiFenKeYongMoney doubleValue]))
        {
            [_passWordView removeFromSuperview];
            _passWordView=nil;
            _passWordView=[[AKsPassWordView alloc]initWithFrame:CGRectMake(0, 0, 493, 354)];
            _passWordView.delegate=self;
            [self.view addSubview:_passWordView];
            
        }
        else
        {
            if(([_tfJiXiao.text floatValue]+[_tfYuXiao.text floatValue])>_yingfuPrice)
            {
                [self showAlter:@"支付金额与应付金额不同，请重新支付"];
            }
            else if([_tfYuXiao.text floatValue]>[netAccess.ChuZhiKeYongMoney floatValue])
            {
                [self showAlter:@"余额消费不足，请重新支付"];
            }
            else if([_tfJiXiao.text floatValue]>[netAccess.JiFenKeYongMoney floatValue])
            {
                [self showAlter:@"积分消费不足，请重新支付"];
            }
        }
    }
    else
    {
        NSLog(@"%d",btn.tag);
    }
    //    else if(204==btn.tag)
    //    {
    //        [_chongzhi removeFromSuperview];
    //        _chongzhi=nil;
    //        _chongzhi=[[AKsVipCaedChongZhiView alloc]initWithFrame:CGRectMake(0, 0, 493, 354)];
    //        _chongzhi.delegate=self;
    //        [self.view addSubview:_chongzhi];
    //    }
    //    else if(205==btn.tag)
    //    {
    ////        [_passWordView2 removeFromSuperview];
    ////        _passWordView2=nil;
    ////        _passWordView2=[[AKsPassWordView2 alloc]initWithFrame:CGRectMake(0, 0, 493, 354)];
    ////        _passWordView2.delegate=self;
    ////        [self.view addSubview:_passWordView2];
    //
    ////        消费撤销
    //        if([_xiaofeiLiusShuiHao isEqualToString:@""])
    //        {
    //            [self showAlter:@"没有会员卡消费，不可执行撤销操作"];
    //        }
    //        else
    //        {
    //            AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    //            netAccess.delegate=self;
    //            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.VipCardNum,@"cardNumber",_xiaofeiLiusShuiHao,@"trace",@"2",@"printtye", @"",@"cardPWD",nil];
    //            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_Undo"]] andPost:dict andTag:card_Undo];
    //            [self.view addSubview:_HUD];
    //        }
    //
    //
    //    }
    
    
}

#pragma mark --AKsPassWordDelegate
-(void)PassWordCancle
{
    [self dismissView];
}
-(void)PassWordSure:(NSString *)passWord
{
    [self dismissView];
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    NSMutableArray *StrArray=[[NSMutableArray alloc]init];
    
    //    优惠劵拼接，同类叠加在一块
    if([_xiaofeiArray count])
    {
        for (int i=0; i<[_xiaofeiArray count]; i++)
        {
            CardJuanClass *juanMessage=(CardJuanClass *)[_xiaofeiArray objectAtIndex:i];
            int Juan_count=[juanMessage.JuanNum intValue];
            NSString *str=[NSString stringWithFormat:@"%@|%@|%@|%d;",juanMessage.JuanId,juanMessage.JuanMoney,juanMessage.JuanName,Juan_count];
            for (int j=i+1; j<[_xiaofeiArray count]; j++)
            {
                if([juanMessage.JuanId isEqualToString:((CardJuanClass *)[_xiaofeiArray objectAtIndex:j]).JuanId])
                {
                    Juan_count++;
                    str=[NSString stringWithFormat:@"%@|%@|%@|%d;",juanMessage.JuanId,juanMessage.JuanMoney,juanMessage.JuanName,Juan_count];
                    [_xiaofeiArray removeObjectAtIndex:j];
                    NSLog(@"%@",str);
                    if([_xiaofeiArray count]!=2)
                    {
                        j-=1;
                    }
                    else
                    {
                        j-=2;
                    }
                }
            }
            if([_xiaofeiArray count]!=1)
            {
                [_xiaofeiArray removeObjectAtIndex:i];
            }
            else
            {
                [_xiaofeiArray removeAllObjects];
            }
            i=0;
            [StrArray addObject:str];
        }
    }
    NSString *str=@"";
    if([StrArray count])
    {
        str=[StrArray objectAtIndex:0];
        for(int i=1;i<[StrArray count];i++)
        {
            str=[str stringByAppendingString:[StrArray objectAtIndex:i]];
        }
    }
    NSLog(@"%@",str);
    
    [self.view addSubview:_HUD];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.VipCardNum,@"cardNumber",_tfYuXiao.text,@"cardStoredAmount",_tfJiXiao.text,@"cardIntegralAmount",_tfXianJin.text,@"cardCashAmount",str,@"cardTicketInfoList",passWord,@"cardPWD",netAccess.zhangdanId ,@"orderId",netAccess.TableNum,@"tableNum",netAccess.IntegralOverall,@"integralOverall", nil];
    NSLog(@"%@=======",dict);
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_Sale"]] andPost:dict andTag:card_Sale];
    
}


-(void)PassWord2Cancle
{
    [self dismissView];
}
-(void)PassWord2Sure:(NSString *)passWord
{
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.VipCardNum,@"cardNumber",@"1",@"trace",@"2",@"printtye", @"123",@"cardPWD",netAccess.zhangdanId, @"orderId",nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_Undo"]] andPost:dict andTag:card_Undo];
    [self.view addSubview:_HUD];
    
}
#pragma mark ---AKsNetAccessDelegate

-(NSArray *)getArrayWithDict:(NSDictionary *)dict andFunction:(NSString *)functionName
{
    NSString *str=[[[dict objectForKey:[NSString stringWithFormat:@"ns:%@Response",functionName]]objectForKey:@"ns:return"]objectForKey:@"text"];
    NSArray *array=[str componentsSeparatedByString:@"@"];
    return array;
}

-(void)showAlter:(NSString *)string
{
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
    });
    
}

//付款
-(void)HHTuserPaymentSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    
    NSArray *array=[self getArrayWithDict:dict andFunction:userPaymentName];
    NSLog(@"%@",array);
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        if(([[array objectAtIndex:0]isEqualToString:@"0"]&&[[array objectAtIndex:1]isEqualToString:@"0"]&&[[array objectAtIndex:2]isEqualToString:@"0"]&&[[array objectAtIndex:3]isEqualToString:@"0"]))
        {
            if([AKsNetAccessClass sharedNetAccess].bukaiFaPiao)
            {
                bs_dispatch_sync_on_main_thread(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结算完成，返回台位界面"
                                                                    message:@"\n"
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    alert.tag=1003;
                    [alert show];
                });
            }
            else
            {
                NSString *str;
                if(zhaolingPrice<=0)
                {
                    str=[NSString stringWithFormat:@"\n"];
                }
                else
                {
                    str=[NSString stringWithFormat:@"\n需找零：%.2f元",zhaolingPrice];
                }
                
                //提示是否打印发票
                //                bs_dispatch_sync_on_main_thread(^{
                //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"结算完成是否开发票%@",str]
                //                                                                    message:@"\n"
                //                                                                   delegate:self
                //                                                          cancelButtonTitle:@"否"
                //                                                          otherButtonTitles:@"是",nil];
                //                    [alert show];
                //                });
                
                
                //不提示是否打印发票
                bs_dispatch_sync_on_main_thread(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"结算完成返回台位界面\n%@",str]
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"确定",nil];
                    [alert show];
                });
                
                
            }
        }
    }
    else
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付失败\n请确定返回全单界面重新支付或\n请去POS完成剩余支付"
                                                            message:@"\n"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            alert.tag=1002;
            [alert show];
        });
    }
    
}

//取消所有的优惠
-(void)HHTcancleUserCounpForWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *array= [self getArrayWithDict:dict andFunction:cancleUserCounpName];
    
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        [self cancleCard];
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                          message:[array lastObject]
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil];
            alert.tag=1001;
            [alert show];
        });
        
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
    
}

//消费撤销
-(void)HHTcard_UndoForWebService:(NSDictionary *)dict
{
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    [_HUD removeFromSuperview];
    NSArray *array=[self getArrayWithDict:dict andFunction:card_UndoName];
    
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        [self cancleCard];
        [self showAlter:@"撤销成功"];
        //        netAccess.IntegralOverall=@"";
        netAccess.yingfuMoney=[NSString stringWithFormat:@"%.2f",_yingfuPrice];
        [self.navigationController popViewControllerAnimated:YES];
        netAccess.zhaolingPrice=[NSString stringWithFormat:@"%.2f",0.0];
        isJuanXiaofei=NO;
        netAccess.shiyongVipJuan=NO;
        
    }
    else
    {
        [self showAlter:@"撤销失败"];
    }
    
}

//结算完成
-(void)HHTinvoiceFaceSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *array= [self getArrayWithDict:dict andFunction:invoiceFaceName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        [self showAlterDelegate:@"结算完成"];
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
    
}

-(void)showAlterDelegate:(NSString *)string
{
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
    });
    //    [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:1] animated:YES];
}

-(void)cancleCard
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCardPayCancle object:nil];
}

-(void)dismissView
{
    if(_passWordView && _passWordView.superclass)
    {
        [_passWordView removeFromSuperview];
        _passWordView=nil;
    }
    if(_chongzhi && _chongzhi.superclass)
    {
        [_chongzhi removeFromSuperview];
        _chongzhi=nil;
    }
    if(_passWordView2 && _passWordView2.superclass)
    {
        [_passWordView2 removeFromSuperview];
        _passWordView2=nil;
    }
}

//会员卡充值
-(void)HHTcard_TopUpForWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    [self dismissView];
    NSArray *array=[self getArrayWithDict:dict andFunction:card_TopUpName];
    if([array count]!=1)
    {
        if([[array objectAtIndex:0]isEqualToString:@"0"])
        {
            //            netAccess.zhongduanNum=@"";
            _tfYuKe.text=[NSString stringWithFormat:@"%@",[array objectAtIndex:2]];
            [AKsNetAccessClass sharedNetAccess].bukaiFaPiao=YES;
        }
        else
        {
            [self showAlter:[array lastObject]];
        }
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
}

//会员卡消费
-(void)HHTcard_SaleForWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    [self dismissView];
    
    NSArray *array=[self getArrayWithDict:dict andFunction:card_SaleName];
    NSLog(@"%@",array);
    chuzhixiaofei=0.0;
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        
        [AKsNetAccessClass sharedNetAccess].xiaofeiliuShui=[array objectAtIndex:1];
        if([_tfJiXiao.text floatValue]!=0 || [_tfYuXiao.text floatValue]!=0)
        {
            AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
            youhui.youName=@"储值消费金额";
            youhui.youMoney=[NSString stringWithFormat:@"%.2f",[_tfJiXiao.text floatValue]+[_tfYuXiao.text floatValue]];
            chuzhixiaofei=[_tfJiXiao.text floatValue]+[[array objectAtIndex:2] floatValue]+[[array objectAtIndex:3]floatValue];
            _yingfuPrice-=[_tfJiXiao.text floatValue]+[[array objectAtIndex:2] floatValue]+[[array objectAtIndex:3]floatValue];
            [_FenXiaoFeiArray addObject:youhui];
            [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCardFenPay object:youhui];
        }
        if([_tfXianJin.text floatValue]!=0)
        {
            AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
            youhui.youName=@"会员卡现金消费";
            [AKsNetAccessClass sharedNetAccess].bukaiFaPiao=NO;
            youhui.youMoney=[NSString stringWithFormat:@"%.2f",[_tfXianJin.text floatValue]];
            [_FenXiaoFeiArray addObject:youhui];
            _yingfuPrice-=[_tfXianJin.text floatValue];
            fapiaoPrice+=[_tfXianJin.text floatValue];
            if(_yingfuPrice<0)
            {
                zhaolingPrice=0-_yingfuPrice;
                _yingfuPrice=0;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCardXianJinPay object:youhui];
        }
        AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
        netAccess.shiyongVipCard=YES;
        netAccess.IntegralOverall=[array objectAtIndex:5];
        
        [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",_yingfuPrice] forKey:@"price"];
        _tfYuXiao.text=[NSString stringWithFormat:@"%.2f",0.0];
        _tfXianJin.text=[NSString stringWithFormat:@"%.2f",0.0];
        _tfJiXiao.text=[NSString stringWithFormat:@"%.2f",0.0];
        isJuanXiaofei=NO;
        
        if(_yingfuPrice<=0)
        {
            
        }
        else
        {
            [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:[self.navigationController.childViewControllers count]-3] animated:YES];
        }
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
    
}

-(void)failedFromWebServie
{
    [_HUD removeFromSuperview];
    bs_dispatch_sync_on_main_thread(^{
        
        
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                      message:@"网络连接失败，请检查网络！"
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil];
        [alert show];
    });
}

#pragma mark --AKsVipChongzhiDelegate

-(void)sureVipChongZhi:(NSString *)money
{
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.VipCardNum,@"cardNumber",money,@"topUpAMT", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_TopUp"]] andPost:dict andTag:card_TopUp];
    [self.view addSubview:_HUD];
}
-(void)cancleVipChongZhi
{
    [self dismissView];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==1001)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag==1002)
    {
        [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:[self.navigationController.viewControllers count]-4] animated:YES];
        //        [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",_yingfuPrice] forKey:@"price"];
    }
    else if(alertView.tag==1003)
    {
        [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:1] animated:YES];
    }
    else
    {
        //        if(buttonIndex==1)
        //        {
        //            AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
        //            netAccess.delegate=self;
        //            [self.view addSubview:_HUD];
        //            NSLog(@"%.2f",fapiaoPrice-zhaolingPrice);
        //            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.zhangdanId,@"orderId",[NSString stringWithFormat:@"%.2f",fapiaoPrice-zhaolingPrice],@"invoiceMoney", nil];
        //            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"invoiceFace"]] andPost:dict andTag:invoiceFace];
        //        }
        //        else
        //        {
        [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:1] animated:YES];
        //        }
    }
}
#pragma mark --AKMysegmentDelegate

-(void)selectSegmentIndex:(NSString *)segmentIndex andSegment:(UISegmentedControl *)segment
{
    
    if(![segmentIndex isEqualToString:@"X"])
    {
        if([[NSString stringWithFormat:@"%d",count]length]>1)
        {
            
        }
        else
        {
            int index=[segmentIndex intValue];
            cishu=cishu*10+index;
            count=cishu;
            NSLog(@"%d",count);
            [segment setSelectedSegmentIndex:11];
            [segment setTitle:[NSString stringWithFormat:@"%d",count] forSegmentAtIndex:11];
        }
    }
    else
    {
        count=1;
        cishu=0;
        [segment setSelectedSegmentIndex:11];
        [segment setTitle:[NSString stringWithFormat:@"%d",count] forSegmentAtIndex:11];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissViews
{
    if(_checkView && _checkView.superview)
    {
        [_checkView removeFromSuperview];
        _checkView=nil;
    }
}

#pragma mark  AKMySegmentAndViewDelegate
-(void)showVipMessageView:(NSArray *)array andisShowVipMessage:(BOOL)isShowVipMessage
{
    if(isShowVipMessage)
    {
        [showVip removeFromSuperview];
        showVip=nil;
    }
    else
    {
        showVip=[[AKsIsVipShowView alloc]initWithArray:array];
        [self.view addSubview:showVip];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //  判断输入的是否为数字小数点和删除键，输入其他字符是不被允许的
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

@end
