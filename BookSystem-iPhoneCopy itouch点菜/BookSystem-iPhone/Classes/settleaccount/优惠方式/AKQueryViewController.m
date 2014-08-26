//预结算界面
//  AKQueryViewController.m
//  BookSystem
//
//  Created by sundaoran on 13-11-23.
//
//

#import "AKQueryViewController.h"
#import "AKDataQueryClass.h"
#import "AKsFenLeiClass.h"
#import "AKsVipViewController.h"
#import "PaymentSelect.h"
#import "AKURLString.h"
#import "CaiDanListCell.h"
#import "MBProgressHUD.h"
#import "AKsYouHuiListClass.h"
#import "AKDataQueryClass.h"
#import "AKsKvoPrice.h"
#import "AKsUserPaymentClass.h"
#import "AKsIsVipShowView.h"
#import "Singleton.h"
#import "AKsNewVipViewController.h"

@implementation AKQueryViewController
{
    NSMutableArray                  *_youmianLeibieArray;
    NSMutableArray                  *_jutiyoumianArray;
    NSMutableArray                  *_dataArray;
    NSMutableArray                  *_youmianShowArray;
    NSMutableArray                  *_youhuiShowArray;
    NSMutableArray                  *_moneyShowArray;
    NSMutableArray                  *_cardYouhuiArray;
    NSMutableArray                  *_FenYouhuiArray;
    NSMutableArray                  *_cardJuanShowArray;
    NSMutableArray                  *_userPaymentArray;
    NSMutableArray                  *_youhuiHuChiArray;
    
    AKQueryAllOrders                *_akao;
    AKsMoneyVIew                    *_moneyView;
    AKsBankView                     *_bankView;
    AKsCheckAouthView               *_checkView;
    
    AKDataQueryClass                *queryDataFromSql;
    AKShowPrivilegeView             *_showSettlement;
    AKsSettlementClass              *_Settlement;
    AKsSettlementClass              *_Settlementlinshi;
    
    float                           caipinPrice;
    float                           fujiaPrice;
    float                           tangshiPrice;
    float                           zongPrice;
    float                           yingfuPrice;
    float                           zhaolingPrice;
    float                           fapiaoPrice;
    float                           molingPrice;
    float                           hejiPrice;
    
    BOOL                            isBack;
    BOOL                            shiyongYouHui;
    BOOL                            shiyougMoney;
    BOOL                            fristCounp;
    
    NSString                        *_SettlementIdChange;
    
    MBProgressHUD                   *_HUD;
    UIView                          *_viewbank;
    UIView                          *_viewmoney;
    AKsKvoPrice                     *_kvoPrice;
    UIPanGestureRecognizer          *_pan;
    AKsIsVipShowView                *showVip;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AKMySegmentAndView *akv=[[AKMySegmentAndView alloc]init];
    akv.frame=CGRectMake(0, 0, 768, 114);
    //    for (int i=2; i<[akv.subviews count]+1; i++)
    //    {
    //        [[akv.subviews lastObject]removeFromSuperview];
    //        i=2;
    //    }
    [[akv.subviews objectAtIndex:1]removeFromSuperview];
    akv.delegate=self;
    [self.view addSubview:akv];
    self.view.backgroundColor=[UIColor whiteColor];
    
    queryDataFromSql= [AKDataQueryClass sharedAKDataQueryClass];
    _youmianLeibieArray =[[NSMutableArray alloc]initWithArray:[queryDataFromSql selectDataFromSqlite:@"SELECT *FROM coupon_kind" andApi:@"分类"]];
    _jutiyoumianArray=[[NSMutableArray alloc]initWithArray:[self changeSegmentSelectMessage:0]];
    
    //    会员卡消费通知中心
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    //如果设置此属性则当前的view置于后台
    _HUD.dimBackground = YES;
    [_HUD show:YES];
    _HUD.labelText = @"数据加载中...";
    _kvoPrice=[[AKsKvoPrice alloc]init];
    
    [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",yingfuPrice] forKey:@"price"];
    [_kvoPrice addObserver:self forKeyPath:@"price" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    NSString *str=[_kvoPrice valueForKey:@"price"];
    NSLog(@"%@",str);
    
    
    UIControl *control=[[UIControl alloc]initWithFrame:self.view.bounds];
    [control addTarget:self action:@selector(ControlClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:control];
    [self.view sendSubviewToBack:control];
    
    _cardYouhuiArray=[[NSMutableArray alloc]init];
    _FenYouhuiArray=[[NSMutableArray alloc]init];
    _youhuiHuChiArray=[[NSMutableArray alloc]init];
    
    [self creatSelectDanHao];
    
    
    _pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tuodongView:)];
    _pan.delaysTouchesBegan=YES;
    
    caipinPrice=0;
    fujiaPrice=0;
    tangshiPrice=0;
    zongPrice=0;
    yingfuPrice=0;
    zhaolingPrice=0;
    fapiaoPrice=0;
    molingPrice=0;
    hejiPrice=0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cardJuanYouHui:) name:NSNotificationCardJuanPay object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cardYouHuiXianJin:) name:NSNotificationCardXianJinPay object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cardYouHuiFen:) name:NSNotificationCardFenPay object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cardJuanYouHuiCancle) name:NSNotificationCardPayCancle object:nil];
    
    
    AKDataQueryClass *data=[[AKDataQueryClass alloc]init];
    
    NSArray *numValues=[data selectDataFromSqlite:[NSString stringWithFormat:@"SELECT * FROM PhoneNumSave WHERE zhangdanId='%@' and dateTime='%@'",[Singleton sharedSingleton].CheckNum,[Singleton sharedSingleton].Time] andApi:@"号码保存"];
    if([numValues count]==1)
    {
        NSDictionary *dict=[numValues objectAtIndex:0];
        [AKsNetAccessClass sharedNetAccess].VipCardNum=[NSString stringWithFormat:@"%@",[dict objectForKey:@"cardNum"]];
        if([[dict objectForKey:@"IntegralOverall"] isEqualToString:@"2"])
        {
            [AKsNetAccessClass sharedNetAccess].IntegralOverall=@"";
        }
        else
        {
            [AKsNetAccessClass sharedNetAccess].IntegralOverall=[NSString stringWithFormat:@"%@",[dict objectForKey:@"IntegralOverall"]];
        }
    }
    else
    {
        [AKsNetAccessClass sharedNetAccess].VipCardNum=@"";
        [AKsNetAccessClass sharedNetAccess].IntegralOverall=@"";
    }
    
    [AKsNetAccessClass sharedNetAccess].bukaiFaPiao=YES;
    [AKsNetAccessClass sharedNetAccess].shiyongVipCard=NO;
}

-(void)ControlClick
{
    [self dismissViews];
}

//界面可拖动
-(void)tuodongView:(UIPanGestureRecognizer *)pan
{
    
    UIView *piece = [pan view];
    NSLog(@"%@",piece);
    if ([pan state] == UIGestureRecognizerStateBegan || [pan state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [pan translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y+ translation.y)];
        [pan setTranslation:CGPointZero inView:self.view];
    }
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    //   订阅通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSNotificationCardFenPay object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSNotificationCardJuanPay object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSNotificationCardPayCancle object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSNotificationCardXianJinPay object:nil];
}

//kvo判断应付金额是否足够，足够后调用支付完成接口
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
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
    
    NSArray *PayArray=[self userPaymenypinjie:_userPaymentArray];
    if([PayArray count])
    {
        NSLog(@"%@",[[PayArray objectAtIndex:1]stringByAppendingString:[NSString stringWithFormat:@"!%.2f",molingPrice]]);
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId",[[PayArray objectAtIndex:3]stringByAppendingString:[NSString stringWithFormat:@"!%@",[array lastObject]]],@"paymentId",[[PayArray objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"!%@",[NSString stringWithFormat:@"%.2f",zhaolingPrice]]],@"paymentCnt",[[PayArray objectAtIndex:1]stringByAppendingString:[NSString stringWithFormat:@"!%.2f",molingPrice]],@"mpaymentMoney",[[PayArray objectAtIndex:4]stringByAppendingString:@"!1"],@"payFinish",netAccess.IntegralOverall,@"integralOverall",netAccess.VipCardNum, @"cardNumber", nil];
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"userPayment"]] andPost:dict andTag:userPayment];
    }
    else
    {
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId",[array lastObject],@"paymentId",[NSString stringWithFormat:@"%.2f",zhaolingPrice],@"paymentCnt",[NSString stringWithFormat:@"%.2f",molingPrice],@"mpaymentMoney",@"1",@"payFinish",netAccess.IntegralOverall,@"integralOverall",netAccess.VipCardNum, @"cardNumber", nil];
        
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"userPayment"]] andPost:dict andTag:userPayment];
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

//抹零
-(void)moling:(NSString *)money
{
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    if([netAccess.baoliuXiaoshu isEqualToString:@"0"])
    {
        //        保留两位小数进行计算
        molingPrice=[[NSString stringWithFormat:@"%.2f",[[NSString stringWithFormat:@"%d", [[NSString stringWithFormat:@"%.2f",[money doubleValue]*100]intValue]%100]doubleValue]/100]doubleValue];
        NSLog(@"%f",molingPrice);
        yingfuPrice=[[NSString stringWithFormat:@"%.2f",[money doubleValue]-molingPrice]doubleValue];
    }
    else if([netAccess.baoliuXiaoshu isEqualToString:@"1"])
    {
        molingPrice=[[NSString stringWithFormat:@"%.2f",[[NSString stringWithFormat:@"%d", [[NSString stringWithFormat:@"%.2f",[money doubleValue]*100]intValue]%10]doubleValue]/100]doubleValue];
        yingfuPrice=[[NSString stringWithFormat:@"%.2f",[money doubleValue]-molingPrice]doubleValue];
    }
    else
    {
        molingPrice=[[NSString stringWithFormat:@"%.2f",0.0]doubleValue];
    }
    
    
    for (int i=0; i<[_youhuiShowArray count]; i++)
    {
        if([((AKsYouHuiListClass *)[_youhuiShowArray objectAtIndex:i]).youName isEqualToString:@"抹零"])
        {
            [_youhuiShowArray removeObjectAtIndex:i];
            break;
        }
    }
    if(molingPrice>0)
    {
        AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
        youhui.youMoney=[NSString stringWithFormat:@"%.2f",molingPrice];
        youhui.youName=@"抹零";
        [_youhuiShowArray addObject:youhui];
    }
    //    [self reloadDataMyself];
    [tvOrder reloadData];
}

-(void)creatSelectDanHao
{
    _akao=[[AKQueryAllOrders alloc]initWithFrame:CGRectMake(0, 0, 493, 354)];
    _akao.deleagte=self;
    //    [self.view addSubview:_akao];
    
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [self.view addSubview:_HUD];
    
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"getOrdersBytabNum"]] andPost:dict andTag:getOrdersBytabNum];
    
}
-(void)creatshowView
{
    tvOrder = [[UITableView alloc] initWithFrame:CGRectMake(4,154-54, 310, 765+54)];
    tvOrder.allowsSelection=NO;
    tvOrder.delegate = self;
    tvOrder.dataSource = self;
    //    [self.view insertSubview:tvOrder belowSubview:btnQuery];
    tvOrder.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    tvOrder.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tvOrder];
    
    UIView *titleImageView=[[UIView alloc]initWithFrame:CGRectMake(4, 124-54, 310, 30)];
    //    [titleImageView setImage:[UIImage imageNamed:@"CommonBG.png"]];
    titleImageView.backgroundColor=[UIColor colorWithRed:26/255.0 green:76/255.0 blue:109/255.0 alpha:1];
    
    //    [btn setBackgroundImage:[UIImage imageNamed:@"cv_rotation_normal_button.png"] forState:UIControlStateNormal];
    //    [btn setBackgroundImage:[UIImage imageNamed:@"cv_rotation_highlight_button.png"] forState:
    
    
    NSArray *array=[[NSArray alloc] initWithObjects:@"取消支付",@"取消优惠",@"现金",@"银行卡",@"会员卡",@"打印",@"返回", nil];
    for (int i=0; i<7; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame=CGRectMake((768-20)/7*i, 1024-70, 130, 50);
        UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(10,20, 120, 30)];
        lb.text=[array objectAtIndex:i];
        lb.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
        lb.backgroundColor=[UIColor clearColor];
        lb.textColor=[UIColor whiteColor];
        [btn addSubview:lb];
        [btn setBackgroundImage:[UIImage imageNamed:@"cv_rotation_normal_button.png"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"cv_rotation_highlight_button.png"] forState:UIControlStateHighlighted];
        //        [btn setBackgroundImage:[UIImage imageNamed:@"TableButtonRed"] forState:UIControlStateNormal];
        //        [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=1000+i;
        btn.tintColor=[UIColor whiteColor];
        [self.view addSubview:btn];
    }
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 310, 30)];
    title.textAlignment = UITextAlignmentCenter;
    title.backgroundColor=[UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:17];
    title.text = @"已点菜品";
    title.textColor=[UIColor whiteColor];
    [titleImageView addSubview:title];
    [self.view addSubview:titleImageView];
    
    //    NSString *pathNormal = [[NSBundle mainBundle] pathForResource:@"TableButtonRed" ofType:@"png"];
    //    NSString *pathSelected = [[NSBundle mainBundle] pathForResource:@"TableButtonPurple" ofType:@"png"];
    //
    //    UIImage *imgNormal = [[UIImage alloc] initWithContentsOfFile:pathNormal];
    //    UIImage *imgSelected = [[UIImage alloc] initWithContentsOfFile:pathSelected];
    //
    //    UIButton *btnback = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnback setBackgroundImage:imgNormal forState:UIControlStateNormal];
    //    [btnback setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    //    [btnback sizeToFit];
    //    btnback.tag=1000;
    //    [btnback setTitle:@"取消支付" forState:UIControlStateNormal];
    //    btnback.titleLabel.font=[UIFont systemFontOfSize:25];
    //
    //    [btnback addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIButton  *btnCancle = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnCancle setBackgroundImage:imgNormal forState:UIControlStateNormal];
    //    [btnCancle setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    //    [btnCancle sizeToFit];
    //    btnCancle.tag=1001;
    //    [btnCancle setTitle:@"取消优惠" forState:UIControlStateNormal];
    //    btnCancle.titleLabel.font=[UIFont systemFontOfSize:25];
    //    [btnCancle addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIButton *btnMoney = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnMoney setBackgroundImage:imgNormal forState:UIControlStateNormal];
    //    [btnMoney setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    //    [btnMoney sizeToFit];
    //    btnMoney.tag=1002;
    //    [btnMoney setTitle:@"现 金" forState:UIControlStateNormal];
    //    btnMoney.titleLabel.font=[UIFont systemFontOfSize:25];
    //    [btnMoney addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIButton *btnBank = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnBank setBackgroundImage:imgNormal forState:UIControlStateNormal];
    //    [btnBank setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    //    [btnBank sizeToFit];
    //    btnBank.tag=1003;
    //    [btnBank setTitle:@"银行卡" forState:UIControlStateNormal];
    //    btnBank.titleLabel.font=[UIFont systemFontOfSize:25];
    //    [btnBank addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIButton *btnVIP = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnVIP setBackgroundImage:imgNormal forState:UIControlStateNormal];
    //    [btnVIP setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    //    [btnVIP sizeToFit];
    //    btnVIP.tag=1004;
    //    [btnVIP setTitle:@"会员卡操作" forState:UIControlStateNormal];
    //    btnVIP.titleLabel.font=[UIFont systemFontOfSize:25];
    //    [btnVIP addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnBack setBackgroundImage:imgNormal forState:UIControlStateNormal];
    //    [btnBack setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    //    [btnBack sizeToFit];
    //    btnBack.tag=1005;
    //    [btnBack setTitle:@"返 回" forState:UIControlStateNormal];
    //    btnBack.titleLabel.font=[UIFont systemFontOfSize:25];
    //    [btnBack addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIButton *btnfaPiao = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnfaPiao setBackgroundImage:imgNormal forState:UIControlStateNormal];
    //    [btnfaPiao setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
    //    [btnfaPiao sizeToFit];
    //    btnfaPiao.tag=1006;
    //    [btnfaPiao setTitle:@"预打印" forState:UIControlStateNormal];
    //    btnfaPiao.titleLabel.font=[UIFont systemFontOfSize:25];
    //    [btnfaPiao addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    btnback.frame=CGRectMake(4, 930, 144, 65);
    //    btnCancle.frame = CGRectMake(154, 930, 144, 65);
    //    btnMoney.frame = CGRectMake(308, 930, 144, 65);
    //    btnBank.frame = CGRectMake(462, 930, 144, 65);
    //    btnVIP.frame=CGRectMake(616, 855, 144, 65);
    //    btnBack.frame=CGRectMake(462, 855, 144, 65);
    //    btnfaPiao.frame=CGRectMake(616, 930, 144, 65);
    //    [self.view addSubview:btnback];
    //    [self.view addSubview:btnCancle];
    //    [self.view addSubview:btnMoney];
    //    [self.view addSubview:btnBank];
    //    [self.view addSubview:btnVIP];
    //    [self.view addSubview:btnBack];
    //    [self.view addSubview:btnfaPiao];
    
    _showSettlement=[[AKShowPrivilegeView alloc]initWithArray:_youmianLeibieArray andSegmentArray:_jutiyoumianArray];
    _showSettlement.frame=CGRectMake(324, 124-54, 430, 690+54);
    _showSettlement.delegate=self;
    [self.view addSubview:_showSettlement];
    
    
    _youmianShowArray=[[NSMutableArray alloc]init];
    _youhuiShowArray=[[NSMutableArray alloc]init];
    _moneyShowArray=[[NSMutableArray alloc]init];
    _cardJuanShowArray=[[NSMutableArray alloc]init];
    _userPaymentArray=[[NSMutableArray alloc]init];
    
    _Settlementlinshi=[[AKsSettlementClass alloc]init];
    
    /*
     ios7屏幕适配
     UIDevice *device = [UIDevice currentDevice];
     float version = [[device systemVersion] floatValue];
     if (version >= 7.0) {
     CGRect viewBounds = self.view.bounds;
     CGFloat topBarOffset = self.topLayoutGuide.length;
     viewBounds.origin.y = topBarOffset * -1;
     self.view.bounds = viewBounds;
     NSLog(@"%f",topBarOffset * -1);
     }
     */
}
-(void)ButtonQuery:(UIButton *)btn
{
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    if(1000==btn.tag)
    {
        if(shiyougMoney)
        {
            for (int j=0; j<[_moneyShowArray count]; j++)
            {
                for(int i=0;i<[_youmianShowArray count];i++)
                {
                    
                    if([_youmianShowArray objectAtIndex:i]==[_moneyShowArray objectAtIndex:j])
                    {
                        
                        yingfuPrice+=[((AKsYouHuiListClass *)[_youmianShowArray objectAtIndex:i]).youMoney floatValue];
                        NSLog(@"%f",yingfuPrice);
                        [_youmianShowArray removeObjectAtIndex:i];
                    }
                }
            }
            shiyougMoney=NO;
            [self cancleZhiFu];
        }
        if(shiyongYouHui)
        {
            [self.view addSubview:_HUD];
            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId", nil];
            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"cancleUserCounp"]] andPost:dict andTag:cancleUserCounp];
        }
        if(netAccess.shiyongVipCard)
        {
            AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
            netAccess.delegate=self;
            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.VipCardNum,@"cardNumber",netAccess.xiaofeiliuShui,@"trace",@"1",@"printtye", @"123",@"cardPWD",netAccess.zhangdanId,@"orderId", nil];
            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_Undo"]] andPost:dict andTag:card_Undo];
            [self.view addSubview:_HUD];
        }
        if((!shiyougMoney) && (!shiyongYouHui) &&(!netAccess.shiyongVipCard))
        {
            [self showAlter:@"无支付记录，不可执行此操作"];
        }
    }
    else if(1001==btn.tag)
    {
        if([AKsNetAccessClass sharedNetAccess].shiyongVipJuan || shiyongYouHui)
        {
            
            [self.view addSubview:_HUD];
            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId", nil];
            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"cancleUserCounp"]] andPost:dict andTag:cancleUserCounp];
        }
        else
        {
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"不存在优惠操作\n不可执行此操作"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
                
            });
        }
    }
    else if(1002==btn.tag)
    {
        AKDataQueryClass *dataQuery=[AKDataQueryClass sharedAKDataQueryClass];
        NSArray *array = [dataQuery selectDataFromSqlite:@"SELECT *FROM settlementoperate WHERE OPERATEGROUPID='5'" andApi:@"现金"];
        
        if([array count]==0)
        {
            if(!_moneyView)
            {
                [self dismissViews];
                _moneyView=[[AKsMoneyVIew alloc]initWithFrame:CGRectMake(0, 0, 493, 354) andName:@"现金" andTag:14 ];
                [_moneyView addGestureRecognizer:_pan];
                [self.view addSubview:_moneyView];
                [_showSettlement setCanuse:NO];
                _moneyView.delegate=self;
            }
            else
            {
                [_moneyView removeFromSuperview];
                [_showSettlement setCanuse:NO];
                _moneyView  =nil;
            }
        }
        else
        {
            if(!_viewmoney)
            {
                [self dismissViews];
                [self greatMonneyView:array];
                [_showSettlement setCanuse:NO];
            }
            else
            {
                [_viewmoney removeFromSuperview];
                [_showSettlement setCanuse:YES];
                _viewmoney  =nil;
            }
        }
        
    }
    else if(1003==btn.tag)
    {
        AKDataQueryClass *dataQuery=[AKDataQueryClass sharedAKDataQueryClass];
        NSArray *array = [dataQuery selectDataFromSqlite:@"SELECT *FROM settlementoperate WHERE OPERATEGROUPID='31'" andApi:@"银行卡"];
        if([array count]==0)
        {
            if(!_bankView )
            {
                [self dismissViews];
                _bankView=[[AKsBankView alloc]initWithFrame:CGRectMake(0, 0, 493, 354) andName:@"银行卡" andTag:1010 andMonry:[NSString stringWithFormat:@"%.2f",yingfuPrice]];
                [_bankView addGestureRecognizer:_pan];
                [self.view addSubview:_bankView];
                [_showSettlement setCanuse:NO];
                _bankView.delegate=self;
            }
            else
            {
                [_bankView removeFromSuperview];
                _bankView=nil;
                [_showSettlement setCanuse:YES];
            }
        }
        else
        {
            if(!_viewbank)
            {
                [self dismissViews];
                [self greatBankView:array];
                [_showSettlement setCanuse:NO];
            }
            else
            {
                [_viewbank removeFromSuperview];
                _viewbank=nil;
                [_showSettlement setCanuse:YES];
                
            }
        }
    }
    else if(1004==btn.tag)
    {
        
        netAccess.yingfuMoney=[NSString stringWithFormat:@"%.2f",yingfuPrice];
        netAccess.molingPrice=[NSString stringWithFormat:@"%.2f",molingPrice];
        [AKsNetAccessClass sharedNetAccess].isVipShow=NO;
        [AKsNetAccessClass sharedNetAccess].userPaymentArray=_userPaymentArray;
        //        AKsVipViewController *vipView=[[AKsVipViewController alloc]init];
        //        [self.navigationController pushViewController:vipView animated:YES];
        
        
        AKsNewVipViewController *newVip=[[AKsNewVipViewController alloc]init];
        [self.navigationController pushViewController:newVip animated:YES];
    }
    else if(1005==btn.tag)
    {
        [self.view addSubview:_HUD];
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId", nil];
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"priPrintOrder"]] andPost:dict andTag:priPrintOrder];
    }
    else if (1006==btn.tag)
    {
        if(isBack)
        {
            [self showAlter:@"已经存在消费，如要返回请取消支付或继续支付完毕"];
        }
        else
        {
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该账单正在结算，是否返回"
                                                                message:@"\n"
                                                               delegate:self
                                                      cancelButtonTitle:@"否"
                                                      otherButtonTitles:@"是",nil];
                alert.tag=100006;
                [alert show];
                
            });
            
        }
        
    }
    else
    {
        NSLog(@"无此操作");
    }
    
}

-(void)reloadDataMyself
{
    tvOrder.contentOffset=CGPointMake(0, ([_moneyShowArray count]+[_youhuiShowArray count]+75)*50);
    [tvOrder reloadData];
}


#pragma mark --AKsVipPayViewControllerNSNotification
-(void)cardJuanYouHui:(id)sender
{
    //    AKDataQueryClass *dataQuery=[AKDataQueryClass sharedAKDataQueryClass];
    //    NSArray *name=[dataQuery selectDataFromSqlite:[NSString stringWithFormat:@"SELECT *FROM settlementoperate WHERE OPERATE='%@'",[array objectAtIndex:2]] andApi:@"优惠显示"];
    isBack=YES;
    AKsYouHuiListClass *youhui=((AKsYouHuiListClass *)[sender object]);
    [_youhuiShowArray addObject:youhui];
    [_cardYouhuiArray addObject:youhui];
    [_cardJuanShowArray addObject:youhui];
    if(yingfuPrice>0)
    {
        yingfuPrice-=[youhui.youMoney floatValue];
        //        [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",yingfuPrice] forKey:@"price"];
    }
    [self reloadDataMyself];
    
}

-(void)cardYouHuiXianJin:(id)sender
{
    isBack=YES;
    AKsYouHuiListClass *youhui=((AKsYouHuiListClass *)[sender object]);
    yingfuPrice-=[youhui.youMoney floatValue];
    fapiaoPrice+=[youhui.youMoney floatValue];
    [_youhuiShowArray addObject:youhui];
    [_cardYouhuiArray addObject:youhui];
    //    if(yingfuPrice<0)
    //    {
    //        zhaolingPrice=0-yingfuPrice;
    //        yingfuPrice=0;
    //
    //    }
    [self reloadDataMyself];
    
}

-(void)cardYouHuiFen:(id)sender
{
    isBack=YES;
    AKsYouHuiListClass *youhui=((AKsYouHuiListClass *)[sender object]);
    [_youhuiShowArray addObject:youhui];
    [_cardYouhuiArray addObject:youhui];
    
    yingfuPrice-=[youhui.youMoney floatValue];
    //    [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",yingfuPrice] forKey:@"price"];
    [self reloadDataMyself];
}


-(void)cardJuanYouHuiCancle
{
    
    for (int j=0; j<[_cardYouhuiArray count]; j++)
    {
        for(int i=0;i<[_youhuiShowArray count];i++)
        {
            
            if([_youhuiShowArray objectAtIndex:i]==[_cardYouhuiArray objectAtIndex:j])
            {
                
                yingfuPrice+=[((AKsYouHuiListClass *)[_youhuiShowArray objectAtIndex:i]).youMoney floatValue];
                NSLog(@"%f",yingfuPrice);
                [_youhuiShowArray removeObjectAtIndex:i];
                //               }
            }
        }
    }
    [self reloadDataMyself];
}


#pragma mark --AKsNetAccessClassDelegate

//发票
-(void)HHTinvoiceFaceSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *array= [self getArrayWithDict:dict andFunction:invoiceFaceName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        [self fapiaoAlterBack:[array lastObject]];
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
}

-(void)fapiaoAlterBack:(NSString *)string
{
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    });
    
}
// 预打印
-(void)HHTpriPrintOrderSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *array= [self getArrayWithDict:dict andFunction:priPrintOrderName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        [self showAlter:[array lastObject]];
        
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
    
}

//查询台号下所有的账单
-(void)HHTgetOrdersBytabNumPayMoneySuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *orders=[self getArrayWithDict:dict andFunction:getOrdersBytabNumName];
    NSLog(@"%@",orders);
    if([[orders objectAtIndex:0]isEqualToString:@"0"])
    {
        //      NSArray *array=[[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4", nil];
        //        NSArray *array=[[NSArray alloc]initWithArray:[[orders objectAtIndex:1]componentsSeparatedByString:@";"]];
        NSMutableArray *ZhangDanArray=[[NSMutableArray alloc]init];
        for (int i=1; i<[orders count]; i++)
        {
            [ZhangDanArray addObject:[orders objectAtIndex:i]];
        }
        if(![[ZhangDanArray objectAtIndex:0]isEqualToString:@""])
        {
            if([ZhangDanArray count]==1)
            {
                AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
                netAccess.zhangdanId=[[[ZhangDanArray lastObject]componentsSeparatedByString:@";"]objectAtIndex:0];
                [_akao setOrderArray:ZhangDanArray];
            }
            else
            {
                [_akao setOrderArray:ZhangDanArray];
                
                [self.view addSubview:_akao];
            }
            
        }
        else
        {
            [self showAlterDelegate:@"该台位暂无账单"];
        }
    }
    else
    {
        [self showAlterDelegate:[orders lastObject]];
    }
}
//查询账单
-(void)HHTqueryProductSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    _dataArray=[[NSMutableArray alloc]init];
    NSString *Content=[[[dict objectForKey:@"ns:queryProductResponse"]objectForKey:@"ns:return" ]objectForKey:@"text"];
    
    NSArray *array=[Content componentsSeparatedByString:@"#"];
    
    NSMutableArray  *caivalueArray=[[NSMutableArray alloc]init];
    NSMutableArray  *payValueArray=[[NSMutableArray alloc]init];
    
    if([array count]==1)
    {
        NSArray *result=[[array objectAtIndex:0]componentsSeparatedByString:@"@"];
        if(![[result objectAtIndex:1]isEqualToString:@"NULL"])
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[result lastObject]
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                alert.tag=100003;
                [alert show];
                
            });
        
    }
    else
    {
        if([array count]==4)
        {
            //         菜品列表
            NSArray *caivalues=[[array firstObject]componentsSeparatedByString:@";"];
            for (int i=0; i<[caivalues count]; i++)
            {
                //    菜品key
                NSArray *caiarrykey=[[NSArray alloc]initWithObjects:@"isok",@"orderid",@"pkid",@"pcode",@"pcname",@"tpcode",@"tpname",@"tpnum",@"pcount",@"promonum",@"fujiacode",@"fujianame",@"price",@"fujiaprice",@"weight",@"weightflag",@"unit",@"istc", nil];
                if(![[caivalues objectAtIndex:i]isEqualToString:@""])
                {
                    
                    NSArray *result=[[caivalues objectAtIndex:i] componentsSeparatedByString:@"@"];
                    NSDictionary *dictData=[[NSDictionary alloc]initWithObjects:result forKeys:caiarrykey];
                    [caivalueArray addObject:dictData];
                }
                else
                {
                    break;
                }
            }
            
            NSArray *payvalues=[[array objectAtIndex:1]componentsSeparatedByString:@";"];
            for (int i=0; i<[payvalues count]; i++)
            {
                //    支付key
                NSArray *payArraykey=[[NSArray alloc]initWithObjects:@"chenggong",@"zhangdan",@"Payname",@"Payprice", nil];
                //            支付方式列表
                if(![[payvalues objectAtIndex:i]isEqualToString:@""])
                {
                    
                    NSArray *result=[[payvalues objectAtIndex:i] componentsSeparatedByString:@"@"];
                    NSDictionary *dictData=[[NSDictionary alloc]initWithObjects:result forKeys:payArraykey];
                    [payValueArray addObject:dictData];
                }
                else
                {
                    break;
                }
            }
        }
        if([caivalueArray count])
        {
            for (int i=0;i<[caivalueArray count] ; i++)
            {
                AKsCanDanListClass *caiList=[[AKsCanDanListClass alloc]init];
                
                //    NSArray *caiArray = [queryDataFromSql selectDataFromSqlite:[NSString stringWithFormat:@"SELECT *FROM food WHERE ITCODE='%@'",[[valueArray objectAtIndex:i]objectForKey:@"pcode"]] andApi:@"菜品查询"];
                //        NSLog(@"%@",[[valueArray objectAtIndex:i]objectForKey:@"pcode"]);
                caiList.isok=[[caivalueArray objectAtIndex:i]objectForKey:@"isok"];
                caiList.istc=[[caivalueArray objectAtIndex:i]objectForKey:@"istc"];
                caiList.fujiacode=[[caivalueArray objectAtIndex:i]objectForKey:@"fujiacode"];
                caiList.fujianame=[[caivalueArray objectAtIndex:i]objectForKey:@"fujianame"];
                caiList.fujiaprice=[[caivalueArray objectAtIndex:i]objectForKey:@"fujiaprice"];
                caiList.orderid=[[caivalueArray objectAtIndex:i]objectForKey:@"orderid"];
                caiList.pcname=[[caivalueArray objectAtIndex:i]objectForKey:@"pcname"];
                caiList.pcode=[[caivalueArray objectAtIndex:i]objectForKey:@"pcode"];
                caiList.pcount=[[caivalueArray objectAtIndex:i]objectForKey:@"pcount"];
                caiList.pkid=[[caivalueArray objectAtIndex:i]objectForKey:@"pkid"];
                caiList.price=[[caivalueArray objectAtIndex:i]objectForKey:@"price"];
                caiList.promonum=[[caivalueArray objectAtIndex:i]objectForKey:@"promonum"];
                caiList.tpcode=[[caivalueArray objectAtIndex:i]objectForKey:@"tpcode"];
                caiList.tpname=[[caivalueArray objectAtIndex:i]objectForKey:@"tpname"];
                caiList.tpnum=[[caivalueArray objectAtIndex:i]objectForKey:@"tpnum"];
                caiList.unit=[[caivalueArray objectAtIndex:i]objectForKey:@"unit"];
                caiList.weight=[[caivalueArray objectAtIndex:i]objectForKey:@"weight"];
                caiList.weightflag=[[caivalueArray objectAtIndex:i]objectForKey:@"weightflag"];
                if([caiList.fujianame length])
                {
                    NSArray *fujiaArray=[caiList.fujianame componentsSeparatedByString:@"!"];
                    NSString *str=[fujiaArray objectAtIndex:0];
                    for (int i=1; i<[fujiaArray count]; i++)
                    {
                        str=[str stringByAppendingString:[NSString stringWithFormat:@",%@",[fujiaArray objectAtIndex:i]]];
                    }
                    caiList.fujianame=str;
                }
                
                caipinPrice+=[caiList.price floatValue];
                fujiaPrice+=[caiList.fujiaprice floatValue];
                [_dataArray addObject:caiList];
            }
            tangshiPrice =caipinPrice+fujiaPrice;
            yingfuPrice=caipinPrice+fujiaPrice;
            
        }
        if([payValueArray count])
        {
            for (int i=0;i<[payValueArray count] ; i++)
            {
                AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
                youhui.youMoney=[[payValueArray objectAtIndex:i]objectForKey:@"Payprice"];
                youhui.youName=[[payValueArray objectAtIndex:i]objectForKey:@"Payname"];
                
                [_youhuiShowArray addObject:youhui];
                
                yingfuPrice-=[youhui.youMoney floatValue];
                isBack=YES;
                shiyongYouHui=YES;
                fristCounp=YES;
                //                [AKsNetAccessClass sharedNetAccess].shiyongVipCard=YES;
            }
        }
        
    }
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    if((!shiyougMoney) && (!shiyongYouHui) &&(!netAccess.shiyongVipCard) && ([caivalueArray count]!=0) && (yingfuPrice<=0))
    {
        [AKsNetAccessClass sharedNetAccess].bukaiFaPiao=YES;
        [tvOrder reloadData];
        [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",yingfuPrice] forKey:@"price"];
    }
    else if((!shiyougMoney) && (!shiyongYouHui) &&(!netAccess.shiyongVipCard) && ([caivalueArray count]==0))
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"该账单没有菜品，确定返回"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            alert.tag=100004;
            [alert show];
            
        });
        
    }
    else
    {
        
        NSLog(@"%@",[NSString stringWithFormat:@"%.2f",yingfuPrice]);
        
        [self moling:[NSString stringWithFormat:@"%.2f",yingfuPrice+molingPrice]];
        [tvOrder reloadData];
        [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",yingfuPrice] forKey:@"price"];
    }
}

//取消所有的优惠
-(void)HHTcancleUserCounpForWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *array= [self getArrayWithDict:dict andFunction:cancleUserCounpName];
    AKsYouHuiListClass *molingYouhui;
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        [self showAlter:[array lastObject]];
        
        for (int j=0; j<[_youhuiShowArray count]; j++)
        {
            if(![((AKsYouHuiListClass *)[_youhuiShowArray objectAtIndex:j]).youName isEqualToString:@"抹零"])
            {
                yingfuPrice+=[((AKsYouHuiListClass *)[_youhuiShowArray objectAtIndex:j]).youMoney floatValue];
                NSLog(@"%f",yingfuPrice);
            }
            else
            {
                molingYouhui=((AKsYouHuiListClass *)[_youhuiShowArray objectAtIndex:j]);
            }
        }
        if(molingYouhui)
        {
            [_youhuiShowArray removeAllObjects];
            [_youhuiShowArray addObject:molingYouhui];
        }
        else
        {
            [_youhuiShowArray removeAllObjects];
        }
        
        for (int j=0; j<[_cardJuanShowArray count]; j++)
        {
            for(int i=0;i<[_youhuiShowArray count];i++)
            {
                
                if([_youhuiShowArray objectAtIndex:i]==[_youhuiShowArray objectAtIndex:j])
                {
                    yingfuPrice+=[((AKsYouHuiListClass *)[_youhuiShowArray objectAtIndex:i]).youMoney floatValue];
                    NSLog(@"%f",yingfuPrice);
                    [_youhuiShowArray removeObjectAtIndex:i];
                    
                }
            }
        }
        
        shiyongYouHui=NO;
        [AKsNetAccessClass sharedNetAccess].shiyongVipJuan=NO;
        [self cancleZhiFu];
        [self reloadDataMyself];
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
}
//取消支付
-(void)HHTcancleUserPaymentSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *array= [self getArrayWithDict:dict andFunction:cancleUserPaymentName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        
        for (int j=0; j<[_moneyShowArray count]; j++)
        {
            for(int i=0;i<[_youmianShowArray count];i++)
            {
                
                if([_youmianShowArray objectAtIndex:i]==[_moneyShowArray objectAtIndex:j])
                {
                    
                    yingfuPrice+=[((AKsYouHuiListClass *)[_youmianShowArray objectAtIndex:i]).youMoney floatValue];
                    NSLog(@"%f",yingfuPrice);
                    [_youmianShowArray removeObjectAtIndex:i];
                }
            }
        }
        //        [_youmianShowArray removeAllObjects];
        shiyougMoney=NO;
        [AKsNetAccessClass sharedNetAccess].bukaiFaPiao=NO;
        [self cancleZhiFu];
        [self reloadDataMyself];
    }
    else
    {
        [self showAlter:@"支付取消失败，重新请求"];
    }
}
//会员卡消费撤销
-(void)HHTcard_UndoForWebService:(NSDictionary *)dict
{
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    [_HUD removeFromSuperview];
    NSArray *array=[self getArrayWithDict:dict andFunction:card_UndoName];
    
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        [self showAlter:@"会员卡消费撤销成功"];
        for (int j=0; j<[_cardYouhuiArray count]; j++)
        {
            for(int i=0;i<[_youhuiShowArray count];i++)
            {
                
                if([_youhuiShowArray objectAtIndex:i]==[_cardYouhuiArray objectAtIndex:j])
                {
                    yingfuPrice+=[((AKsYouHuiListClass *)[_youhuiShowArray objectAtIndex:i]).youMoney floatValue];
                    NSLog(@"%f",yingfuPrice);
                    [_youhuiShowArray removeObjectAtIndex:i];
                }
            }
        }
        netAccess.shiyongVipCard=NO;
        [self cancleZhiFu];
        [self reloadDataMyself];
    }
    else
    {
        [self showAlter:@"撤销失败"];
    }
}
-(void)cancleZhiFu
{
    if((!shiyongYouHui) && (!shiyougMoney) && (![AKsNetAccessClass sharedNetAccess].shiyongVipCard))
    {
        [self showAlterDelegate:@"支付取消成功"];
        //        [self.navigationController popViewControllerAnimated:YES];
        isBack=NO;
    }
}

-(void)userPaymentbaocun:(NSString *)money andit:(NSString *)item andName:(NSString *)Name
{
    if(fristCounp)
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"已使用优惠结算\n如要使用本操作\n请取消支付后重新支付"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        });

    }
    else
    {
        isBack=YES;
        shiyougMoney=YES;
        AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
        youhui.youMoney=money;
        AKDataQueryClass *dataQuery=[AKDataQueryClass sharedAKDataQueryClass];
        NSArray *name=[dataQuery selectDataFromSqlite:[NSString stringWithFormat:@"SELECT *FROM settlementoperate WHERE OPERATE='%@'",item] andApi:@"现金显示"];
        
        youhui.youName=[name lastObject];
        
        AKsUserPaymentClass *userPay=[[AKsUserPaymentClass alloc]init];
        userPay.userpaymentMoney=money;
        userPay.userpaymentName=[name lastObject];
        userPay.userpaymentTag=item;
        userPay.userpaymentCount=@"1";
        
        [_userPaymentArray addObject:userPay];
        [_youmianShowArray addObject:youhui];
        [_moneyShowArray addObject:youhui];
        yingfuPrice-=[money floatValue];
        fapiaoPrice+=[money floatValue];
        
        if(yingfuPrice<=0)
        {
            zhaolingPrice=0-yingfuPrice;
            yingfuPrice=0;
            
        }
        [self moling:[NSString stringWithFormat:@"%.2f",yingfuPrice+molingPrice]];
        [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",yingfuPrice] forKey:@"price"];
        
        //    [self reloadDataMyself];
    }
}

//付款
-(void)HHTuserPaymentSuccessFormWebService:(NSDictionary *)dict
{
    
    [_HUD removeFromSuperview];
    [self dismissViews];
    //    NSString *str=[[[dict objectForKey:@"ns:userPaymentResponse"]objectForKey:@"ns:return"]objectForKey:@"text"];
    NSArray *array=[self getArrayWithDict:dict andFunction:userPaymentName];
    NSLog(@"%@",array);
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        if(!([[array objectAtIndex:0]isEqualToString:@"0"]&&[[array objectAtIndex:1]isEqualToString:@"0"]&&[[array objectAtIndex:2]isEqualToString:@"0"]&&[[array objectAtIndex:3]isEqualToString:@"0"]))
        {
            //            AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
            //            youhui.youMoney=[array objectAtIndex:3];
            //
            //            AKDataQueryClass *dataQuery=[AKDataQueryClass sharedAKDataQueryClass];
            //            NSArray *name=[dataQuery selectDataFromSqlite:[NSString stringWithFormat:@"SELECT *FROM settlementoperate WHERE OPERATE='%@'",[array objectAtIndex:1]] andApi:@"现金显示"];
            //
            //            youhui.youName=[name lastObject];
            //            [_youmianShowArray addObject:youhui];
            //            [_moneyShowArray addObject:youhui];
            //            yingfuPrice-=[[array objectAtIndex:3] floatValue];
            //            fapiaoPrice+=[[array objectAtIndex:3] floatValue];
            ////            [AKsNetAccessClass sharedNetAccess].fapiaoPrice=[NSString stringWithFormat:@"%.2f",fapiaoPrice-zhaolingPrice];
            //            if(yingfuPrice<0)
            //            {
            //                zhaolingPrice=0-yingfuPrice;
            //                yingfuPrice=0;
            ////                [AKsNetAccessClass sharedNetAccess].yingfuMoney=[NSString stringWithFormat:@"%.2f",yingfuPrice];
            //            }
            //
            //            [self moling:[NSString stringWithFormat:@"%.2f",yingfuPrice+molingPrice]];
            //
            
        }
        else
        {
            if([AKsNetAccessClass sharedNetAccess].bukaiFaPiao)
            {
                bs_dispatch_sync_on_main_thread(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结算完成，返回台位界面"
                                                                    message:@"\n"
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    alert.tag=100005;
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
                
                //                提示是否开发票
                //                bs_dispatch_sync_on_main_thread(^{
                //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"结算完成是否开发票%@",str]
                //                                                                    message:@"\n"
                //                                                                   delegate:self
                //                                                          cancelButtonTitle:@"否"
                //                                                          otherButtonTitles:@"是",nil];
                //                    [alert show];
                //                });
                
                
                //                不提示开发票，确定返回台位界面
                bs_dispatch_sync_on_main_thread(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"结算完成返回台位界面\n%@",str]
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"确定",nil];
                    [alert show];
                });
                
                
            }
            isBack=YES;
            shiyougMoney=YES;
            
        }
    }
    else
    {
        NSLog(@"%@",[array lastObject]);
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付失败\n请确定返回全单界面重新支付或\n请去POS完成剩余支付"
                                                            message:@"\n"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            
            alert.tag=100002;
            [alert show];
        });
    }
}
//优惠操作
-(void)HHTuserCounpSuccessFormWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    NSArray *array=[self getArrayWithDict:dict andFunction:userCounpName];
    
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        if([_youhuiHuChiArray count]==0)
        {
            [_youhuiHuChiArray addObject:_Settlementlinshi];
        }
        if(_Settlement)
        {
            [_youhuiHuChiArray addObject:_Settlement];
        }
        AKDataQueryClass *dataQuery=[AKDataQueryClass sharedAKDataQueryClass];
        NSArray *name=[dataQuery selectDataFromSqlite:[NSString stringWithFormat:@"SELECT *FROM settlementoperate WHERE OPERATE='%@'",[array objectAtIndex:2]] andApi:@"优惠显示"];
        
        AKsYouHuiListClass *youhui=[[AKsYouHuiListClass alloc]init];
        youhui.youMoney=[array objectAtIndex:5];
        youhui.youName=[name lastObject];
        //        [_youmianShowArray addObject:youhui];
        [_youhuiShowArray addObject:youhui];
        yingfuPrice-=[[array objectAtIndex:5] floatValue];
        
        
        [self moling:[NSString stringWithFormat:@"%.2f",yingfuPrice+molingPrice]];
        [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",yingfuPrice] forKey:@"price"];
        
        isBack=YES;
        shiyongYouHui=YES;
        fristCounp=YES;
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
}
//链接失败
-(void)failedFromWebServie
{
    [_HUD removeFromSuperview];
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                  message:@"网络连接失败，请检查网络！\n然后重新支付"
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
    
    alert.tag=100007;
    [alert show];
    
    //    [self showAlterDelegate:@"网络连接失败，请检查网络！"];
}


//获取所有的账单失败并返回前一界面
-(void)HHTgetOrdersBytabNumfailedFromWebServie
{
    [_HUD removeFromSuperview];
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                  message:@"网络连接失败，请检查网络！\n然后重新支付"
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
    alert.tag=100008;
    [alert show];
    
}

//提示框显示
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
//提示框显示并且添加代理事件
-(void)showAlterDelegate:(NSString *)string
{
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
    });
    [self.navigationController popViewControllerAnimated:YES];
}

//解析请求数据
-(NSArray *)getArrayWithDict:(NSDictionary *)dict andFunction:(NSString *)functionName
{
    NSString *str=[[[dict objectForKey:[NSString stringWithFormat:@"ns:%@Response",functionName]]objectForKey:@"ns:return"]objectForKey:@"text"];
    NSArray *array=[str componentsSeparatedByString:@"@"];
    return array;
}

#pragma mark --AKsBankyDelegate
//银行卡消费界面代理事件
-(void)sureBank:(NSString *)money andName:(NSString *)name andTag:(int)btnTag andMonry:(NSString *)textmoney
{
    if([money floatValue]<=yingfuPrice && yingfuPrice>0)
    {
        [_bankView removeFromSuperview];
        _bankView=nil;
        if(yingfuPrice>0)
        {
            [AKsNetAccessClass sharedNetAccess].bukaiFaPiao=NO;
            [self userPaymentbaocun:money andit:[NSString stringWithFormat:@"%d",btnTag] andName:name];
            //        AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
            //        netAccess.delegate=self;
            //        [self.view addSubview:_HUD];
            //        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId",[NSString stringWithFormat:@"%d",btnTag],@"paymentId",@"1",@"paymentCnt",money,@"mpaymentMoney",@"0",@"payFinish", nil];
            //        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"userPayment"]] andPost:dict andTag:userPayment];
        }
        else
        {
            [self showAlter:@"已结算完成，无需再次支付！"];
        }
    }
    else
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"输入金额必须少于应付金额，或与支付金额相同"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            
        });
        
    }
    
}
-(void)cancleBank
{
    [_bankView removeFromSuperview];
    _bankView=nil;
    
}

#pragma mark --AKsMoneyDelegate
//现金消费界面代理事件
-(void)sureMoney:(NSString *)money andName:(NSString *)name andTag:(int)btnTag
{
    [_moneyView removeFromSuperview];
    _moneyView=nil;
    
    if(yingfuPrice>0)
    {
        [AKsNetAccessClass sharedNetAccess].bukaiFaPiao=NO;
        [self userPaymentbaocun:money andit:[NSString stringWithFormat:@"%d",btnTag] andName:name];
        //        AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
        //        netAccess.delegate=self;
        //        [self.view addSubview:_HUD];
        //        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId",[NSString stringWithFormat:@"%d",btnTag],@"paymentId",@"1",@"paymentCnt",money,@"mpaymentMoney",@"0",@"payFinish", nil];
        //        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"userPayment"]] andPost:dict andTag:userPayment];
    }
    else
    {
        [self showAlter:@"已结算完成，无需再次支付！"];
    }
    
}

-(void)cancleMoney
{
    [_moneyView removeFromSuperview];
    _moneyView=nil;
}


#pragma mark --AKShowPrivilegeViewDelegate
//显示所有的优惠方式
-(void)changeSegmentSelect:(NSInteger)selectIndex
{
    [_showSettlement removeFromSuperview];
    _showSettlement=nil;
    
    _jutiyoumianArray=[[NSMutableArray alloc]initWithArray:[self changeSegmentSelectMessage:selectIndex]];
    [self dismissViews];
    if(!_showSettlement)
    {
        _showSettlement=[[AKShowPrivilegeView alloc]initWithArray:_youmianLeibieArray andSegmentArray:_jutiyoumianArray];
        _showSettlement.frame=CGRectMake(324, 124-54, 430, 690+54);
        _showSettlement.delegate=self;
        [self.view addSubview:_showSettlement];
    }
    
}

-(NSArray *)changeSegmentSelectMessage:(NSInteger)index
{
    //    优惠方式是从本地的数据库中获取
    NSString *string=((AKsFenLeiClass *)[_youmianLeibieArray objectAtIndex:index]).fenLeiId;
    NSString *yuju=[NSString stringWithFormat:@"SELECT *FROM coupon_main WHERE KINDID='%@' and ISSHOW='1'",string];
    NSArray *array=[[NSArray alloc]initWithArray:[queryDataFromSql selectDataFromSqlite:yuju andApi:@"分类信息"]];
    return array;
}

-(void)changeButtonSelect:(AKsSettlementClass *)selectButton
{
    BOOL isHuChi=[self isYouHuiHuChi:_youhuiHuChiArray andSettlementId:selectButton];
    if(yingfuPrice >0)
    {
        if(isHuChi)
        {
            if(!_checkView )
            {
                [self dismissViews];
                _checkView=[[AKsCheckAouthView alloc]initWithFrame:CGRectMake(0, 0, 493, 354) andSettlment:selectButton];
                //                _checkView.frame=CGRectMake(0, 0, 493, 354);
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
            [NSThread detachNewThreadSelector:@selector(changbuttonThread:) toTarget:self withObject:selectButton.SettlementId];
        }
        
    }
    else
    {
        [self showAlter:@"账单已结清，不可使用相应优惠方式"];
    }
    
}

//判断是否存在优惠互斥
-(BOOL)isYouHuiHuChi:(NSMutableArray *)array andSettlementId:(AKsSettlementClass *)SettlementId
{
    BOOL isHuChi;
    int count=0;
    if([array count]==0)
    {
        //        [_youhuiHuChiArray addObject:SettlementId];
        _Settlementlinshi=SettlementId;
        return NO;
    }
    
    for (int i=0; i<[array count]; i++)
    {
        NSLog(@"%@====>",SettlementId);
        NSLog(@"%@---->",((AKsSettlementClass *)[array objectAtIndex:i]).SettlementId);
        if([SettlementId.SettlementId isEqualToString:((AKsSettlementClass *)[array objectAtIndex:i]).SettlementId])
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

-(void)changbuttonThread:(NSString *)SettlementId
{
    _SettlementIdChange=SettlementId;
    if(fristCounp)
    {
        [self userCoump:SettlementId];
    }
    else
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定执行优惠支付\n支付成功后将不可进行现金操作"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定",nil];
            alert.tag=100009;
            [alert show];
        });
    }
}

-(void)userCoump:(NSString *)SettlementId
{
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [self.view addSubview:_HUD];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.zhangdanId,@"orderId",SettlementId,@"counpId",@"1",@"counpCnt",[NSString stringWithFormat:@"%f",yingfuPrice],@"counpMoney", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"userCounp"]] andPost:dict andTag:userCounp];
}

#pragma mark  互斥授权
-(void)sureAKsCheckAouthView:(AKsSettlementClass *)Settlement andUserName:(NSString *)name andUserPass:(NSString *)pass
{
    _Settlement=[[AKsSettlementClass alloc]init];
    _Settlement=Settlement;
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
        [NSThread detachNewThreadSelector:@selector(changbuttonThread:) toTarget:self withObject:_Settlement.SettlementId];
        
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

-(void)greatBankView:(NSArray *)array
{
    //    [self dismissViews];
    _viewbank=[[UIView alloc]initWithFrame:CGRectMake(134, 300, 470, 300)];
    _viewbank.backgroundColor=[UIColor colorWithRed:26/255.0 green:76/255.0 blue:109/255.0 alpha:1];
    [_viewbank addGestureRecognizer:_pan];
    for (int i=0; i<[array count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateHighlighted];
        button.titleLabel.font=[UIFont systemFontOfSize:20];
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        [button setTitle:[NSString stringWithFormat:@"%@",((AKsSettlementClass *)[array objectAtIndex:i]).SettlementName] forState:UIControlStateNormal];
        button.tag=[((AKsSettlementClass *)[array objectAtIndex:i]).SettlementId intValue];
        [button addTarget:self action:@selector(ButtonClickBank:) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(i%3*150+10,i/3*75+10, 140, 65);
        [_viewbank addSubview:button];
        
    }
    [self.view addSubview:_viewbank];
}

-(void)greatMonneyView:(NSArray *)array
{
    //    [self dismissViews];
    _viewmoney=[[UIView alloc]initWithFrame:CGRectMake(134, 300, 470, 300)];
    _viewmoney.backgroundColor=[UIColor colorWithRed:26/255.0 green:76/255.0 blue:109/255.0 alpha:1];
    [_viewmoney addGestureRecognizer:_pan];
    
    for (int i=0; i<[array count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateHighlighted];
        button.titleLabel.font=[UIFont systemFontOfSize:20];
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        [button setTitle:[NSString stringWithFormat:@"%@",((AKsSettlementClass *)[array objectAtIndex:i]).SettlementName] forState:UIControlStateNormal];
        button.tag=[((AKsSettlementClass *)[array objectAtIndex:i]).SettlementId intValue];
        [button addTarget:self action:@selector(ButtonClickMoney:) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(i%3*150+10,i/3*75+10, 140, 65);
        [_viewmoney addSubview:button];
    }
    [self.view addSubview:_viewmoney];
}


-(void)ButtonClickBank:(UIButton *)button
{
    
    [self dismissViews];
    if(!_bankView )
    {
        _bankView=[[AKsBankView alloc]initWithFrame:CGRectMake(0, 0, 493, 354) andName:button.titleLabel.text andTag:button.tag andMonry:[NSString stringWithFormat:@"%.2f",yingfuPrice]];
        [_bankView addGestureRecognizer:_pan];
        [self.view addSubview:_bankView];
        _bankView.delegate=self;
    }
    else
    {
        [_bankView removeFromSuperview];
        _bankView=nil;
    }
}

-(void)ButtonClickMoney:(UIButton *)button
{
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    netAccess.yingfuMoney=[NSString stringWithFormat:@"%.2f",yingfuPrice];
    
    if(yingfuPrice<=0)
    {
        zhaolingPrice=yingfuPrice;
    }
    [self dismissViews];
    if(!_moneyView)
    {
        _moneyView=[[AKsMoneyVIew alloc]initWithFrame:CGRectMake(0, 0, 493, 354) andName:button.titleLabel.text andTag:button.tag ];
        [_moneyView addGestureRecognizer:_pan];
        [self.view addSubview:_moneyView];
        _moneyView.delegate=self;
    }
    else
    {
        [_moneyView removeFromSuperview];
        _moneyView=nil;
    }
}

#pragma mark --AKQueryAllOrdersDelegate
//多个未结算账单，可选择
-(void)ordersSelectSure:(NSString *)orderNum
{
    [_akao removeFromSuperview];
    _akao=nil;
    [self creatshowView];
    
    [NSThread detachNewThreadSelector:@selector(ThreadOrder:) toTarget:self withObject:orderNum];
}
-(void)ThreadOrder:(NSString *)orderNum
{
    
    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
    netAccess.delegate=self;
    [self.view addSubview:_HUD];
    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.PeopleManNum,@"manCounts",netAccess.PeopleWomanNum,@"womanCounts",netAccess.zhangdanId,@"orderId",@"1",@"chkCode",@"1",@"comOrDetach", nil];
    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"queryProduct"]] andPost:dict andTag:queryProduct];
    
}

-(void)ordersSelectCancle
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --UItableViewDelegate

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return [_dataArray count];
    }
    else if(section==1)
    {
        return [_youhuiShowArray count];
    }
    else if(section==2)
    {
        return [_moneyShowArray count];
    }
    else
        return 0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        return 75;
    }
    else
    {
        return 50;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section==0)
    {
        return 37;
    }
    else  if(section==1)
    {
        return 50;
    }
    else if(section==3)
    {
        return 75;
    }
    else
    {
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName=@"cell";
    CaiDanListCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell==nil)
    {
        cell=[[CaiDanListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    if(indexPath.section==0)
    {
        //        菜品显示
        [cell setCellForArray:[_dataArray objectAtIndex:indexPath.row]];
        
    }
    else if(indexPath.section==1)
    {
        //        结算方式显示
        [cell setCellForAKsYouHuiList:[_youhuiShowArray objectAtIndex:indexPath.row]];
    }
    else if (indexPath.section==2)
    {
        [cell setCellForAKsYouHuiList:[_moneyShowArray objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 310, 75)];
    if(section==0)
    {
        //        view.backgroundColor=[UIColor redColor];
        UILabel *count=[[UILabel alloc]initWithFrame:CGRectMake(0,37-37, 60, 37)];
        count.textAlignment=NSTextAlignmentCenter;
        count.text=@"数量";
        count.backgroundColor=[UIColor clearColor];
        count.font=[UIFont systemFontOfSize:17];
        [view addSubview:count];
        
        UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(60,37-37, 190, 37)];
        name.textAlignment=NSTextAlignmentCenter;
        name.text=@"名称";
        name.backgroundColor=[UIColor clearColor];
        name.font=[UIFont systemFontOfSize:17];
        [view addSubview:name];
        
        UILabel *Price=[[UILabel alloc]initWithFrame:CGRectMake(250,37-37, 60, 37)];
        Price.textAlignment=NSTextAlignmentCenter;
        Price.text=@"价格";
        Price.backgroundColor=[UIColor clearColor];
        Price.font=[UIFont systemFontOfSize:17];
        [view addSubview:Price];
    }
    else if(section==1)
    {
        //         view.backgroundColor=[UIColor yellowColor];
        //        if([_jutiyoumianArray count]!=0)
        //        {
        
        UILabel *YouName=[[UILabel alloc]initWithFrame:CGRectMake(0+20,0, 155-20, 24)];
        YouName.textAlignment=NSTextAlignmentLeft;
        YouName.text=@"账单金额:";
        YouName.backgroundColor=[UIColor clearColor];
        YouName.font=[UIFont systemFontOfSize:17];
        [view addSubview:YouName];
        
        
        UILabel *YouMoney=[[UILabel alloc]initWithFrame:CGRectMake(155-8,0, 155, 24)];
        YouMoney.textAlignment=NSTextAlignmentRight;
        YouMoney.text=[NSString stringWithFormat:@"%.2f",tangshiPrice];
        YouMoney.backgroundColor=[UIColor clearColor];
        YouMoney.font=[UIFont systemFontOfSize:17];
        [view addSubview:YouMoney];
        
        //        }
    }
    else if(section==2)
    {
        view.frame=CGRectMake(0, 0, 310, 0);
    }
    else if(section==3)
    {
        //         view.backgroundColor=[UIColor blueColor];
        UILabel *hejiName=[[UILabel alloc]initWithFrame:CGRectMake(0+20,0, 155-20, 24)];
        hejiName.textAlignment=NSTextAlignmentLeft;
        hejiName.text=@"应收金额:";
        hejiName.backgroundColor=[UIColor clearColor];
        hejiName.font=[UIFont systemFontOfSize:17];
        [view addSubview:hejiName];
        
        
        UILabel *hejiMoney=[[UILabel alloc]initWithFrame:CGRectMake(155-8,0, 155, 24)];
        hejiMoney.textAlignment=NSTextAlignmentRight;
        hejiMoney.text=[NSString stringWithFormat:@"%.2f",yingfuPrice+molingPrice];
        hejiMoney.backgroundColor=[UIColor clearColor];
        hejiMoney.font=[UIFont systemFontOfSize:17];
        [view addSubview:hejiMoney];
        
        
        
        UILabel *PayName=[[UILabel alloc]initWithFrame:CGRectMake(0+20,24, 155-20, 24)];
        PayName.textAlignment=NSTextAlignmentLeft;
        PayName.text=@"应付金额:";
        PayName.backgroundColor=[UIColor clearColor];
        PayName.font=[UIFont systemFontOfSize:17];
        [view addSubview:PayName];
        
        
        UILabel *PayMoney=[[UILabel alloc]initWithFrame:CGRectMake(155-8,24, 155, 24)];
        PayMoney.textAlignment=NSTextAlignmentRight;
        if(yingfuPrice>0)
        {
            PayMoney.text=[NSString stringWithFormat:@"%.2f",yingfuPrice];
        }
        else
        {
            PayMoney.text=@"0.00";
        }
        PayMoney.backgroundColor=[UIColor clearColor];
        PayMoney.font=[UIFont systemFontOfSize:17];
        [view addSubview:PayMoney];
        
        
        UILabel *BackName=[[UILabel alloc]initWithFrame:CGRectMake(0+20,24+24, 155-20, 24)];
        BackName.textAlignment=NSTextAlignmentLeft;
        BackName.text=@"找  零:";
        BackName.backgroundColor=[UIColor clearColor];
        BackName.font=[UIFont systemFontOfSize:17];
        [view addSubview:BackName];
        
        UILabel *BackMoney=[[UILabel alloc]initWithFrame:CGRectMake(155-8,24+24, 155, 24)];
        BackMoney.textAlignment=NSTextAlignmentRight;
        BackMoney.text=[NSString stringWithFormat:@"%.2f",zhaolingPrice];
        BackMoney.backgroundColor=[UIColor clearColor];
        BackMoney.font=[UIFont systemFontOfSize:17];
        [view addSubview:BackMoney];
        
    }
    
    view.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    return view;
}
- (void)dismissViews{
    [_showSettlement setCanuse:YES];
    if (_moneyView && _moneyView.superview){
        [_moneyView removeFromSuperview];
        _moneyView = nil;
    }
    if (_bankView && _bankView.superview){
        [_bankView removeFromSuperview];
        _bankView = nil;
    }
    if (_viewbank && _viewbank.superview){
        [_viewbank removeFromSuperview];
        _viewbank = nil;
    }
    if(_viewmoney && _viewmoney.superview)
    {
        [_viewmoney removeFromSuperview];
        _viewmoney = nil;
    }
    if(_checkView && _checkView.superview)
    {
        [_checkView removeFromSuperview];
        _checkView = nil;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
}


#pragma mark alterViewDelegate
//-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100002)
    {
        [self.navigationController popViewControllerAnimated:YES];
        //        [_kvoPrice setValue:[NSString stringWithFormat:@"%.2f",yingfuPrice] forKey:@"price"];
    }
    else if(alertView.tag==100003)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag==100004)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag==100005)
    {
        [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:1] animated:YES];
    }
    else if(alertView.tag==100006)
    {
        if(buttonIndex==1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if(alertView.tag==100007)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag==100008)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag==100009)
    {
        if(buttonIndex==1)
        {
            [self userCoump:_SettlementIdChange];
        }
    }
    else//是否开发票
    {
        //        if(buttonIndex==1)
        //        {
        //
        //            AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
        //            netAccess.delegate=self;
        //            [self.view addSubview:_HUD];
        //            NSLog(@"%@",[NSString stringWithFormat:@"%.2f",fapiaoPrice-zhaolingPrice]);
        //            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.zhangdanId,@"orderId",[NSString stringWithFormat:@"%.2f",fapiaoPrice-zhaolingPrice],@"invoiceMoney", nil];
        //            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"invoiceFace"]] andPost:dict andTag:invoiceFace];
        //        }
        //        else
        //        {
        [self.navigationController popToViewController:[self.navigationController.childViewControllers objectAtIndex:1] animated:YES];
        //        }
    }
}

#pragma mysegmentDelegate

-(void)selectSegmentIndex:(NSString *)segmentIndex andSegment:(UISegmentedControl *)segment
{
    
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



@end
