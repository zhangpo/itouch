//会员卡查询
//  AKsVipCardQueryView.m
//  BookSystem
//
//  Created by sundaoran on 13-12-4.
//
//

#import "AKsVipCardQueryView.h"
#import "CardJuanClass.h"
#import "PaymentSelect.h"
#import "AKDataQueryClass.h"


@implementation AKsVipCardQueryView
{
    UITextField                     *_CardNumTf;
    
    UILabel                         *lblCardNum;
    UILabel                         *lblCardYu;
    UILabel                         *lblCardYuShow;
    UILabel                         *lblCardJi;
    UILabel                         *lblCardJiShow;
    //    UILabel                         *lblCardJiKe;
    //    UILabel                         *lblCardJiKeShow;
    UILabel                         *lblCardJuan;
    UILabel                         *lblCardJuanShow;
    UILabel                         *lblCardJuanKe;
    UILabel                         *lblCardJuanKeShow;
    UILabel                         *lblMessage;
    UILabel                         *title;
    
    UILabel                         *noCardJuan;
    
    UIButton                        *_orderButton;
    UITableView                     *_tableView;
    UITableView                     *_tableViewCard;
    BOOL                            ischange;
    NSMutableArray                  *_orderArray;
    NSMutableArray                  *_dataJuanArray;
    
    UIButton                        *buttonCancle;
    UIButton                        *buttonSure;
    UIButton                        *buttonQuery;
    UIButton                        *buttonPay;
    UIButton                        *buttonDianCai;
    
    AKsPassWordView                 *_AkPassView;
    MBProgressHUD                   *_HUD;
}
@synthesize delegate=_delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatView];
    }
    return self;
}

-(void)creatView
{
    _HUD=[[MBProgressHUD alloc]initWithView:self];
    _HUD.labelText=@"数据加载中...";
    _HUD.dimBackground=YES;
    [_HUD show:YES];
    
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
  /*
   
   不显示自定义的segment
    UILabel *tableNumber=[[UILabel alloc]initWithFrame:CGRectMake(17,54, 250, 50)];
    tableNumber.textAlignment=NSTextAlignmentCenter;
    if([netAccess.TableNum length]==11)
    {
        tableNumber.text=[NSString stringWithFormat:@"手机号：%@号",netAccess.TableNum];
    }
    else
    {
        tableNumber.text=[NSString stringWithFormat:@"桌台号：%@号",netAccess.TableNum];
    }
    tableNumber.backgroundColor=[UIColor clearColor];
    tableNumber.font=[UIFont systemFontOfSize:20];
    [self addSubview:tableNumber];
    
    UILabel *saleNum=[[UILabel alloc]initWithFrame:CGRectMake(234,54, 300, 50)];
    saleNum.textAlignment=NSTextAlignmentCenter;
    saleNum.backgroundColor=[UIColor clearColor];
    saleNum.font=[UIFont systemFontOfSize:20];
    if(netAccess.zhangdanId==NULL)
    {
        saleNum.text=[NSString stringWithFormat:@"账单号：不存在账单"];
    }
    else
    {
        saleNum.text=[NSString stringWithFormat:@"账单号：%@",netAccess.zhangdanId];
        
    }
    [self addSubview:saleNum];
    
    UILabel *peopleNum=[[UILabel alloc]initWithFrame:CGRectMake(551,54, 200, 50)];
    peopleNum.textAlignment=NSTextAlignmentCenter;
    peopleNum.text=[NSString stringWithFormat:@"人数：%d人",[netAccess.PeopleWomanNum intValue]+[netAccess.PeopleManNum intValue]];
    peopleNum.backgroundColor=[UIColor clearColor];
    peopleNum.font=[UIFont systemFontOfSize:20];
    [self addSubview:peopleNum];
    
   */
    UILabel *lblmoney=[[UILabel alloc]initWithFrame:CGRectMake(17,104-30, 250, 50)];
    lblmoney.textAlignment=NSTextAlignmentCenter;
    lblmoney.text=[NSString stringWithFormat:@"应付金额：%@元",netAccess.yingfuMoney];
    lblmoney.backgroundColor=[UIColor clearColor];
    lblmoney.font=[UIFont systemFontOfSize:20];
    
    if(!(netAccess.yingfuMoney==NULL))
    {
        [self addSubview:lblmoney];
    }
    
    lblCardNum=[[UILabel alloc]initWithFrame:CGRectMake(20,54+100, 130, 50)];
    lblCardNum.textAlignment=NSTextAlignmentLeft;
    lblCardNum.text=@"手机号码:";
    lblCardNum.backgroundColor=[UIColor clearColor];
    lblCardNum.font=[UIFont systemFontOfSize:20];
    [self addSubview:lblCardNum];
    
    AKDataQueryClass *data=[[AKDataQueryClass alloc]init];
    
    
    NSArray *numValues;
    if([netAccess.TableNum length]!=11)
    {
        numValues=[data selectDataFromSqlite:[NSString stringWithFormat:@"SELECT * FROM PhoneNumSave WHERE zhangdanId='%@' and dateTime='%@'",netAccess.zhangdanId,[Singleton sharedSingleton].Time] andApi:@"号码保存"];
    }
    
    
    _CardNumTf=[[UITextField alloc]initWithFrame:CGRectMake(120, 54+100, 260, 50)];
    _CardNumTf.borderStyle=UITextBorderStyleRoundedRect;
    _CardNumTf.backgroundColor=[UIColor whiteColor];
    _CardNumTf.clearButtonMode=UITextFieldViewModeAlways;
    _CardNumTf.placeholder=@"请输入账号";
    _CardNumTf.delegate=self;
    _CardNumTf.keyboardType=UIKeyboardTypeNumberPad;
    _CardNumTf.font=[UIFont systemFontOfSize:23];
    [self addSubview:_CardNumTf];
//    (400,124+100, 130, 50)
//    (540,124+100, 210, 50)
    lblCardYu=[[UILabel alloc]initWithFrame:CGRectMake(400,124+100, 130, 50)];
    lblCardYu.textAlignment=NSTextAlignmentLeft;
    lblCardYu.text=@"储值卡余额:";
    lblCardYu.backgroundColor=[UIColor clearColor];
    lblCardYu.font=[UIFont systemFontOfSize:20];
    [self addSubview:lblCardYu];
    
    lblCardYuShow=[[UILabel alloc]initWithFrame:CGRectMake(520,124+100, 230, 50)];
    lblCardYuShow.textAlignment=NSTextAlignmentRight;
    lblCardYuShow.text=@"";
    lblCardYuShow.layer.cornerRadius=5;
    lblCardYuShow.backgroundColor=[UIColor whiteColor];
    lblCardYuShow.font=[UIFont systemFontOfSize:23];
    [self addSubview:lblCardYuShow];
    
    
    lblCardJi=[[UILabel alloc]initWithFrame:CGRectMake(20,194+100, 130, 50)];
    lblCardJi.textAlignment=NSTextAlignmentLeft;
    lblCardJi.text=@"积分余额:";
    lblCardJi.backgroundColor=[UIColor clearColor];
    lblCardJi.font=[UIFont systemFontOfSize:20];
    [self addSubview:lblCardJi];
    
    lblCardJiShow=[[UILabel alloc]initWithFrame:CGRectMake(120, 194+100, 260, 50)];
    lblCardJiShow.textAlignment=NSTextAlignmentRight;
    lblCardJiShow.text=@"";
    lblCardJiShow.layer.cornerRadius=5;
    lblCardJiShow.backgroundColor=[UIColor whiteColor];
    lblCardJiShow.font=[UIFont systemFontOfSize:23];
    [self addSubview:lblCardJiShow];
    
    
    //    lblCardJiKe=[[UILabel alloc]initWithFrame:CGRectMake(400,124+100, 130, 50)];
    //    lblCardJiKe.textAlignment=NSTextAlignmentLeft;
    //    lblCardJiKe.text=@"积分可用余额:";
    //    lblCardJiKe.backgroundColor=[UIColor clearColor];
    //    lblCardJiKe.font=[UIFont systemFontOfSize:20];
    //    [self addSubview:lblCardJiKe];
    //
    //    lblCardJiKeShow=[[UILabel alloc]initWithFrame:CGRectMake(540,124+100, 210, 50)];
    //    lblCardJiKeShow.textAlignment=NSTextAlignmentRight;
    //    lblCardJiKeShow.text=@"";
    //    lblCardJiKeShow.layer.cornerRadius=5;
    //    lblCardJiKeShow.backgroundColor=[UIColor whiteColor];
    //    lblCardJiKeShow.font=[UIFont systemFontOfSize:23];
    //    [self addSubview:lblCardJiKeShow];
    
    
    
    lblCardJuan=[[UILabel alloc]initWithFrame:CGRectMake(20,124+100, 130, 50)];
    lblCardJuan.textAlignment=NSTextAlignmentLeft;
    lblCardJuan.text=@"劵余额:";
    lblCardJuan.backgroundColor=[UIColor clearColor];
    lblCardJuan.font=[UIFont systemFontOfSize:20];
    [self addSubview:lblCardJuan];
    
    lblCardJuanShow=[[UILabel alloc]initWithFrame:CGRectMake(120, 124+100, 260, 50)];
    lblCardJuanShow.textAlignment=NSTextAlignmentRight;
    lblCardJuanShow.text=@"";
    lblCardJuanShow.layer.cornerRadius=5;
    lblCardJuanShow.backgroundColor=[UIColor whiteColor];
    lblCardJuanShow.font=[UIFont systemFontOfSize:23];
    [self addSubview:lblCardJuanShow];
    
    
    
//    卷可用余额改为会员卡号
    lblCardJuanKe=[[UILabel alloc]initWithFrame:CGRectMake(400,54+100, 130, 50)];
    lblCardJuanKe.textAlignment=NSTextAlignmentLeft;
    lblCardJuanKe.text=@"会员卡号:";
    lblCardJuanKe.backgroundColor=[UIColor clearColor];
    lblCardJuanKe.font=[UIFont systemFontOfSize:20];
    [self addSubview:lblCardJuanKe];
    
    lblCardJuanKeShow=[[UILabel alloc]initWithFrame:CGRectMake(520,54+100, 230, 50)];
    lblCardJuanKeShow.textAlignment=NSTextAlignmentRight;
    lblCardJuanKeShow.text=@"";
    lblCardJuanKeShow.layer.cornerRadius=5;
    lblCardJuanKeShow.backgroundColor=[UIColor whiteColor];
    lblCardJuanKeShow.font=[UIFont systemFontOfSize:23];
    [self addSubview:lblCardJuanKeShow];
    
    if([numValues count]==1)
    {
        NSDictionary *dict=[numValues objectAtIndex:0];
        
        _CardNumTf.text=[dict objectForKey:@"phoneNum"];
        lblCardJuanKeShow.text=[dict objectForKey:@"cardNum"];
    }
    else if(netAccess.phoneNum)
    {
        _CardNumTf.text=netAccess.phoneNum;
        
    }

    
    title=[[UILabel alloc]initWithFrame:CGRectMake(0,260+100, 768,40)];
    title.textAlignment=NSTextAlignmentCenter;
    title.text=@"劵信息列表";
    title.layer.cornerRadius=5;
    title.backgroundColor=[UIColor clearColor];
    title.font=[UIFont systemFontOfSize:18];
    [self addSubview:title];
    
    lblMessage=[[UILabel alloc]initWithFrame:CGRectMake(20,310+100,728, 300)];
    lblMessage.textAlignment=NSTextAlignmentCenter;
    lblMessage.text=@"请输入正确的手机号码后点击确定按钮并等待通讯结束......";
    lblMessage.lineBreakMode=NSLineBreakByCharWrapping;
    lblMessage.numberOfLines=3;
    lblMessage.backgroundColor=[UIColor whiteColor];
    lblMessage.textColor=[UIColor greenColor];
    lblMessage.font=[UIFont systemFontOfSize:40];
    [self addSubview:lblMessage];
    
    
    _orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [_orderButton setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]];
    [_orderButton setBackgroundImage:[UIImage imageNamed:@"cardNumDown.png"] forState:UIControlStateNormal];
    _orderButton.frame=CGRectMake(20, 710-60, 728, 60);
    _orderButton.titleLabel.font=[UIFont systemFontOfSize:40];
    _orderButton.tintColor=[UIColor blackColor];
    _orderButton.titleLabel.textAlignment=UITextAlignmentLeft;
    [_orderButton addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(20,610+100, 728, 180) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    
    ischange=YES;
    
    _tableViewCard=[[UITableView alloc]initWithFrame:CGRectMake(20,310+100, 728, 300) style:UITableViewStylePlain];
    _tableViewCard.backgroundColor=[UIColor whiteColor];
    _tableViewCard.delegate=self;
    _tableViewCard.dataSource=self;
    
    noCardJuan=[[UILabel alloc]initWithFrame:CGRectMake(20,310+100, 728, 300)];
    noCardJuan.backgroundColor=[UIColor whiteColor];
    noCardJuan.textAlignment=UITextAlignmentCenter;
    noCardJuan.font=[UIFont boldSystemFontOfSize:20];
    noCardJuan.layer.cornerRadius=5;
    noCardJuan.text=@"该会员卡暂无劵可显示...";
    
    
    buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    [buttonCancle setTitle:@"取 消" forState:UIControlStateNormal];
    buttonCancle.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    buttonCancle.tag=2001;
    [buttonCancle addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    buttonCancle.frame=CGRectMake(650, 740,80,40);
    [self addSubview:buttonCancle];
    
    buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
    buttonSure.tag=2002;
    buttonSure.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [buttonSure addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    buttonSure.frame=CGRectMake(550, 740,80,40);
    [self addSubview:buttonSure];
    
    buttonQuery = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonQuery setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonQuery setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    [buttonQuery setTitle:@"查 询" forState:UIControlStateNormal];
    buttonQuery.tag=2003;
    buttonQuery.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [buttonQuery addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    buttonQuery.frame=CGRectMake(550, 740, 80,40);
    
    
    buttonPay = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonPay setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonPay setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    [buttonPay setTitle:@"支 付" forState:UIControlStateNormal];
    buttonPay.tag=2004;
    buttonPay.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [buttonPay addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    buttonPay.frame=CGRectMake(550, 740, 80,40);
    
    buttonDianCai = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonDianCai setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonDianCai setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    [buttonDianCai setTitle:@"点菜" forState:UIControlStateNormal];
    buttonDianCai.tag=2005;
    buttonDianCai.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [buttonDianCai addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    buttonDianCai.frame=CGRectMake(550, 740,80,40);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
    
}

//#pragma mark  -AKsVipPayViewControllerDelegate
//
//-(void)refushVipCardMessage
//{
//    AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
//    netAccess.delegate=self;
//    NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",_CardNumTf.text,@"cardNumber",netAccess.zhangdanId,@"orderId", nil];
//    [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_QueryBalance"]] andPost:dict andTag:card_QueryBalance];
//    [self addSubview:_HUD];
//
//}



//键盘显示
-(void)keyboardWillShow
{
    [_delegate controlClick:_CardNumTf];
    [UIView animateWithDuration:0.18 animations:^{
        lblMessage.frame=CGRectMake(20,310+100, 728, 300-80);
        _orderButton.frame=CGRectMake(20, 710-60-80, 728, 60);
        buttonSure.frame=CGRectMake(550, 740-80,80,40);
        buttonQuery.frame=CGRectMake(550, 740-80,80,40);
        buttonPay.frame=CGRectMake(550, 740-80,80,40);
        buttonDianCai.frame=CGRectMake(550, 740-80,80,40);
        buttonCancle.frame=CGRectMake(650, 740-80, 80,40);
        _tableView.frame=CGRectMake(20,610+100-80, 728, 180);
        _tableViewCard.frame=CGRectMake(20,310+100, 728, 300-80);
        noCardJuan.frame=CGRectMake(20,310+100, 728, 300-80);
    } completion:^(BOOL finished) {
        
    }];
}

//键盘隐藏
-(void)keyboardWillHide
{
    [UIView animateWithDuration:0.18 animations:^{
        lblMessage.frame=CGRectMake(20,310+100,728, 300);
        _orderButton.frame=CGRectMake(20, 710-60, 728, 60);
        buttonSure.frame=CGRectMake(550, 740, 80,40);
        buttonQuery.frame=CGRectMake(550, 740,80,40);
        buttonPay.frame=CGRectMake(550, 740, 80,40);
        buttonDianCai.frame=CGRectMake(550, 740, 80,40);
        buttonCancle.frame=CGRectMake(650, 740,80,40);
        _tableView.frame=CGRectMake(20,610+100, 728, 180);
        _tableViewCard.frame=CGRectMake(20,310+100, 728, 300);
        noCardJuan.frame=CGRectMake(20,310+100, 728, 300);
    } completion:^(BOOL finished) {
        
    }];
    
}

//-(void)ControlClick
//{
//  [_CardNumTf resignFirstResponder];
//}

-(void)ButtonQuery:(UIButton *)btn
{
    if(2001==btn.tag)
    {
        [_delegate VipCardCancle];
    }
    else if(2002==btn.tag)
    {
        if(([_CardNumTf.text length]!=11) && ([_CardNumTf.text length]!=16))
        {
            [self showAlter:@"请输入正确的手机号码"];
        }
        else if([_CardNumTf.text length]==11)
        {
            AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
            netAccess.delegate=self;
            netAccess.phoneNum=_CardNumTf.text;
            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",_CardNumTf.text,@"phoneNumber", nil];
            NSLog(@"%@",_CardNumTf.text);
            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_GetTrack2"]] andPost:dict andTag:card_GetTrack2];
            [self addSubview:_HUD];
            
        }
//        else if([_CardNumTf.text length]==16)
//        {
//            AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
//            netAccess.delegate=self;
//            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",lblCardJuanKeShow.text,@"cardNumber",netAccess.zhangdanId,@"orderId", nil];
//            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_QueryBalance"]] andPost:dict andTag:card_QueryBalance];
//            [self addSubview:_HUD];
//        }
        
    }
    else if(2003==btn.tag)
    {
        //        密码
        //        if ([_CardNumTf.text length]==16)
        //        {
        //            if(!_AkPassView)
        //            {
        //                _AkPassView=[[AKsPassWordView alloc]initWithFrame:CGRectMake(0, 0, 493, 354)];
        //                _AkPassView.delegate=self;
        //                [self addSubview:_AkPassView];
        //            }
        //            else
        //            {
        //                [_AkPassView removeFromSuperview];
        //                _AkPassView=nil;
        //            }
        //        }
        
        AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
        netAccess.delegate=self;
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",lblCardJuanKeShow.text,@"cardNumber",netAccess.zhangdanId,@"orderId", nil];
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_QueryBalance"]] andPost:dict andTag:card_QueryBalance];
        [self addSubview:_HUD];
        
    }
    else if(2004==btn.tag)
    {
        [_delegate ClickPayButton:_dataJuanArray];
    }
    else if(2005==btn.tag)
    {
        [_delegate ClickDiancaiView];
    }
    
}
-(void)dismissViews
{
    if(_AkPassView && _AkPassView.superview)
    {
        [_AkPassView removeFromSuperview];
        _AkPassView=nil;
    }
}

-(void)ButtonClick:(UIButton *)btn
{
    if(ischange)
    {
        [_CardNumTf resignFirstResponder];
        [self addSubview:_tableView];
        [_orderButton setBackgroundImage:[UIImage imageNamed:@"cardNumRight.png"] forState:UIControlStateNormal];
        ischange=NO;
        [UIView animateWithDuration:0.13 animations:^{
            buttonSure.frame=CGRectMake(550, 740+180, 80,40);
            buttonQuery.frame=CGRectMake(550, 740+180, 80,40);
            buttonPay.frame=CGRectMake(550, 740+180, 80,40);
            buttonDianCai.frame=CGRectMake(550, 740+180,80,40);
            buttonCancle.frame=CGRectMake(650, 740+180,80,40);
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [_orderButton setBackgroundImage:[UIImage imageNamed:@"cardNumDown.png"] forState:UIControlStateNormal];
        [_tableView removeFromSuperview];
        ischange =YES;
        [UIView animateWithDuration:0.13 animations:^{
            buttonSure.frame=CGRectMake(550, 740, 80, 40);
            buttonQuery.frame=CGRectMake(550, 740,80, 40);
            buttonPay.frame=CGRectMake(550, 740, 80, 40);
            buttonDianCai.frame=CGRectMake(550, 740, 80, 40);
            buttonCancle.frame=CGRectMake(650, 740, 80, 40);
        } completion:^(BOOL finished) {
            
        }];
    }
    
}


#pragma mark --AKsNetAccessDelegate

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
                                                        message:@"\n"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
    });
    
}

// 查询手机号下所有的会员卡号
-(void)HHTcard_GetTrack2ForWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    
    NSArray *array=[self getArrayWithDict:dict andFunction:card_GetTrack2Name];
    NSLog(@"%@",array);
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        
        NSArray *values=[[array objectAtIndex:2]componentsSeparatedByString:@";"];
        
        if(([values count]==1)&& ([[values objectAtIndex:0]length]!=16))
        {
            [self showAlter:@"该手机号下暂无注册会员卡"];
        }
        else
        {
            AKDataQueryClass *data=[[AKDataQueryClass alloc]init];
            NSArray *numValues=[data selectDataFromSqlite:[NSString stringWithFormat:@"SELECT * FROM PhoneNumSave WHERE zhangdanId='%@'",[AKsNetAccessClass sharedNetAccess].zhangdanId] andApi:@"号码保存"];
            
            int count=0;
            for (NSDictionary *dict in numValues)
            {
                if([[dict objectForKey:@"zhangdanId"]isEqualToString:[AKsNetAccessClass sharedNetAccess].zhangdanId] && (![[dict objectForKey:@"phoneNum"]isEqualToString:_CardNumTf.text]))
                {
                    [data delectPhoneNumWhithZhangdanId:[AKsNetAccessClass sharedNetAccess].zhangdanId];
                    [data savePhoneNumWhithZhangdanId:_CardNumTf.text andZhangDanId:[AKsNetAccessClass sharedNetAccess].zhangdanId];
                    count++;
                    break;
                }
                else
                {
                    count++;
                }
            }
            if(count==0)
            {
                [data savePhoneNumWhithZhangdanId:_CardNumTf.text andZhangDanId:[AKsNetAccessClass sharedNetAccess].zhangdanId];
            }
            //    刷新会员信息
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refushVipMessage" object:nil];
            
            _orderArray=[[NSMutableArray alloc]initWithArray:values];
            
            if(![lblCardJuanKeShow.text isEqualToString:@""])
            {
                for (int i=0; i<[_orderArray count]; i++)
                {
                    if([lblCardJuanKeShow.text isEqualToString:[_orderArray objectAtIndex:i]])
                    {
                        [_orderArray exchangeObjectAtIndex:i withObjectAtIndex:0];
                        break;
                    }
                }
            }
            
            [_orderButton setTitle:[NSString stringWithFormat:@"%@",[_orderArray objectAtIndex:0]] forState:UIControlStateNormal];
            lblCardJuanKeShow.text=[NSString stringWithFormat:@"%@",[_orderArray objectAtIndex:0]];
            
            AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
            netAccess.VipCardNum= lblCardJuanKeShow.text;
            
            [self addSubview:_orderButton];
            [_CardNumTf resignFirstResponder];
            [buttonSure removeFromSuperview];
            buttonSure=nil;
            [self addSubview:buttonQuery];
            lblMessage.text=@"输入手机卡号会有多张会员卡，请选择使用卡号，输入密码，并点击查询继续↓......↓";
//            lblCardNum.text=@"会员卡号:";
            [_tableView reloadData];
        }
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
    
}
//。。。。。。。。。。。
//查询会员卡信息
-(void)HHTcard_QueryBalanceForWebService:(NSDictionary *)dict
{
    [_HUD removeFromSuperview];
    _dataJuanArray=[[NSMutableArray alloc]init];
    NSArray *array=[self getArrayWithDict:dict andFunction:card_QueryBalanceName];
    
    
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
        AKDataQueryClass *data=[[AKDataQueryClass alloc]init];
        
        
        lblCardJiShow.text=[array objectAtIndex:4];
        [AKsNetAccessClass sharedNetAccess].IntegralOverall=[array objectAtIndex:4];
        
        lblCardJuanShow.text=[array objectAtIndex:5];
//        lblCardJuanKeShow.text=[array objectAtIndex:6];
        lblCardYuShow.text=[array objectAtIndex:3];
        
        netAccess.JiFenKeYongMoney=[array objectAtIndex:4];
        netAccess.ChuZhiKeYongMoney=[array objectAtIndex:3];
        
        NSArray *VipJuan=[[NSArray alloc]initWithArray:[[array lastObject]componentsSeparatedByString:@";"]];
        NSMutableDictionary *cardJuanDict=[[NSMutableDictionary alloc]init];
        for (int i=0; i<[VipJuan count]-1; i++)
        {
            
            NSArray *values=[[VipJuan objectAtIndex:i] componentsSeparatedByString:@","];
            
            CardJuanClass *cardJuan=[[CardJuanClass alloc]init];
            cardJuan.JuanId=[values objectAtIndex:0];
            cardJuan.JuanMoney=[NSString stringWithFormat:@"%.2f",[[values objectAtIndex:1]floatValue]/100.0];
            cardJuan.JuanName=[values objectAtIndex:2];
            cardJuan.JuanNum=[values objectAtIndex:3];
            
            [cardJuanDict setObject:cardJuan.JuanName forKey:cardJuan.JuanId];
            
            [_dataJuanArray addObject:cardJuan];
        }
        
        [AKsNetAccessClass sharedNetAccess].CardJuanDict=cardJuanDict;
        
        
        [data saveCardNumforVip:netAccess.VipCardNum andPhoneNum:netAccess.phoneNum andzhangdanId:netAccess.zhangdanId andIntegralOverall:netAccess.IntegralOverall];
        
        //    刷新会员信息
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refushVipMessage" object:nil];
        
        [_HUD removeFromSuperview];
        [lblMessage removeFromSuperview];
        [_orderButton removeFromSuperview];
        [buttonQuery removeFromSuperview];
        if([AKsNetAccessClass sharedNetAccess].isVipShow)
        {
            [self addSubview:buttonDianCai];
        }
        else
        {
            [self addSubview:buttonPay];
        }
        
        if([_dataJuanArray count]==0)
        {
            [self addSubview:noCardJuan];
        }
        else
        {
            [self addSubview:_tableViewCard];
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


#pragma mark AKPassWordDelegate

-(void)PassWordCancle
{
    [self dismissViews];
    [self addSubview:lblMessage];
    [self addSubview:_orderButton];
    
}
-(void)PassWordSure:(NSString *)passWord
{
    NSLog(@"%@",passWord);
    NSLog(@"%@",_CardNumTf.text);
    
    [self dismissViews];
    [lblMessage removeFromSuperview];
    [_orderButton removeFromSuperview];
    [buttonQuery removeFromSuperview];
    [self addSubview:buttonPay];
    [self addSubview:_tableViewCard];
    
}
#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView==_tableView)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==_tableView)
    {
        return [_orderArray count];
    }
    else
    {
        return [_dataJuanArray count];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView)
    {
        return 60;
    }
    else
    {
        return 60;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView)
    {
        static NSString *cellName=@"cell";
        UITableViewCell *cell=[_tableView dequeueReusableCellWithIdentifier:cellName];
        if(cell==nil)
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        cell.textLabel.text=[_orderArray objectAtIndex:indexPath.row];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *cellName2=@"cell2";
        UITableViewCell *cell=[_tableViewCard dequeueReusableCellWithIdentifier:cellName2];
        if(cell==nil)
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName2];
        }
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        for (int j=0; j<3; j++)
        {
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((j+1)*182,5, 1, 50)];
            label.backgroundColor=[UIColor blackColor];
            label.alpha=0.5;
            [cell.contentView addSubview:label];
        }
        for(int i=0 ;i<4;i++)
        {
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(i*182,0, 182, 60)];
            label.textAlignment=NSTextAlignmentCenter;
            label.backgroundColor=[UIColor clearColor];
            label.font=[UIFont systemFontOfSize:20];
            switch (i) {
                case 0:
                    label.text=((CardJuanClass *)[_dataJuanArray objectAtIndex:indexPath.row]).JuanId;
                    break;
                case 1:
                    label.text=[NSString stringWithFormat:@"%@(元)",((CardJuanClass *)[_dataJuanArray objectAtIndex:indexPath.row]).JuanMoney];
                    break;
                case 2:
                    label.text=((CardJuanClass *)[_dataJuanArray objectAtIndex:indexPath.row]).JuanName;
                    break;
                case 3:
                    label.text=[NSString stringWithFormat:@"%@(张)",((CardJuanClass *)[_dataJuanArray objectAtIndex:indexPath.row]).JuanNum];
                    break;
                default:
                    break;
            }
            [cell.contentView addSubview:label];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView)
    {
        [_orderButton setTitle:[NSString stringWithFormat:@"%@",[_orderArray objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        [_tableView removeFromSuperview];
        ischange=YES;
        lblCardJuanKeShow.text=_orderButton.titleLabel.text;
        AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
        netAccess.VipCardNum=_orderButton.titleLabel.text;
        [_orderButton setBackgroundImage:[UIImage imageNamed:@"cardNumDown.png"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.13 animations:^{
            buttonSure.frame=CGRectMake(550, 740,80, 40);
            buttonQuery.frame=CGRectMake(550, 740,80, 40);
            buttonPay.frame=CGRectMake(550, 740, 80, 40);
            buttonDianCai.frame=CGRectMake(550, 740, 80, 40);
            buttonCancle.frame=CGRectMake(650, 740,80, 40);
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
    if([string isEqualToString:@""])
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
