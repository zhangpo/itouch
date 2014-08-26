//
//  AKsNewVipViewController.m
//  BookSystem
//
//  Created by sundaoran on 14-3-5.
//
//

#import "AKsNewVipViewController.h"
#import "AKsVipPayViewController.h"
#import "AKDataQueryClass.h"
#import "AKsNewVipMessageShowCell.h"
#import "AKsIsVipShowView.h"

@interface AKsNewVipViewController ()

@end

@implementation AKsNewVipViewController
{
    AKMySegmentAndView      *akv;
    AKsNewVipMessageShowView *_showMessage;
    AKsIsVipShowView        *showVip;
    UILabel                 *_phoneNum;
    UILabel                 *_userName;
    UILabel                 *_userSex;
    UILabel                 *_userAge;
    UILabel                 *_useridentifiy;
    UILabel                 *_userEmail;
    
    UILabel                 *_userNameShow;
    UILabel                 *_userSexShow;
    UILabel                 *_userAgeShow;
    UILabel                 *_useridentifiyShow;
    UILabel                 *_userEmailShow;
    UILabel                 *_title;
    UILabel                 *_lblMessage;
    UILabel                 *noCardJuan;
    
    UITextField             *_phoneNumShow;
    
    UIButton                *buttonCancle;
    UIButton                *buttonSure;
    MBProgressHUD           *_HUD;
    
    NSMutableArray          *_orderArray;
    NSMutableArray          *_dataJuanArray;
    
    UITableView             *_tableView;
    UITableView             *_tableViewCard;
    
    NSMutableDictionary     *_vipDict;
    
    NSString                *isChaxun;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view becomeFirstResponder];

    akv=[[AKMySegmentAndView alloc]init];
    akv.delegate=self;
    akv.frame=CGRectMake(0, 0, 768, 44);
    //    for (int i=1; i<[akv.subviews count]+1; i++)
    //    {
    //        [[akv.subviews lastObject]removeFromSuperview];
    //        i=1;
    //    }
    [[akv.subviews objectAtIndex:1]removeFromSuperview];
    [self.view addSubview:akv];


}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:193/255.0f green:193/255.0f blue:193/255.0f alpha:1];
    
    [self greatView];
    
    _HUD=[[MBProgressHUD alloc]initWithView:self.view];
    _HUD.labelText=@"数据加载中...";
    _HUD.dimBackground=YES;
    [_HUD show:YES];

}

-(void)greatView
{
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    
    UILabel *lblmoney=[[UILabel alloc]initWithFrame:CGRectMake(17,104-50, 250, 50)];
    lblmoney.textAlignment=NSTextAlignmentCenter;
    lblmoney.text=[NSString stringWithFormat:@"应付金额：%@元",netAccess.yingfuMoney];
    lblmoney.backgroundColor=[UIColor clearColor];
    lblmoney.font=[UIFont systemFontOfSize:20];
    if(!(netAccess.yingfuMoney==NULL))
    {
        [self.view addSubview:lblmoney];
    }

    _phoneNum=[[UILabel alloc]initWithFrame:CGRectMake(20,54+50, 130, 50)];
    _phoneNum.textAlignment=NSTextAlignmentLeft;
    _phoneNum.text=@"手机号码:";
    _phoneNum.backgroundColor=[UIColor clearColor];
    _phoneNum.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:_phoneNum];
    
    AKDataQueryClass *data=[[AKDataQueryClass alloc]init];
    
    
    _phoneNumShow=[[UITextField alloc]initWithFrame:CGRectMake(120, 54+50, 260, 50)];
    _phoneNumShow.borderStyle=UITextBorderStyleRoundedRect;
    _phoneNumShow.backgroundColor=[UIColor whiteColor];
    _phoneNumShow.clearButtonMode=UITextFieldViewModeAlways;
    _phoneNumShow.placeholder=@"请输入手机号";
    _phoneNumShow.delegate=self;
    _phoneNumShow.keyboardType=UIKeyboardTypeNumberPad;
    _phoneNumShow.font=[UIFont systemFontOfSize:23];
    [_phoneNumShow becomeFirstResponder];
    [self.view addSubview:_phoneNumShow];
    
    NSArray *numValues=[[NSArray alloc]init];
    if([netAccess.TableNum length]!=11)
    {
        numValues=[data selectDataFromSqlite:[NSString stringWithFormat:@"SELECT * FROM PhoneNumSave WHERE zhangdanId='%@' and dateTime='%@'",netAccess.zhangdanId,[Singleton sharedSingleton].Time] andApi:@"号码保存"];
    }
    
    if([numValues count]==1)
    {
        NSDictionary *dictValue=[numValues objectAtIndex:0];
        
        _phoneNumShow.text=[dictValue objectForKey:@"phoneNum"];
        if([dictValue objectForKey:@"cardNum"])
        {
            isChaxun=[dictValue objectForKey:@"cardNum"];
        }
    }
    else if(netAccess.phoneNum)
    {
        _phoneNumShow.text=netAccess.phoneNum;
        isChaxun=[AKsNetAccessClass sharedNetAccess].VipCardNum;
    }
    


    _userName=[[UILabel alloc]initWithFrame:CGRectMake(400,54+50, 130, 50)];
    _userName.textAlignment=NSTextAlignmentLeft;
    _userName.text=@"姓名:";
    _userName.backgroundColor=[UIColor clearColor];
    _userName.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:_userName];
    
    _userNameShow=[[UILabel alloc]initWithFrame:CGRectMake(520,54+50, 230, 50)];
    _userNameShow.textAlignment=NSTextAlignmentRight;
    _userNameShow.text=@"";
    _userNameShow.layer.cornerRadius=5;
    _userNameShow.backgroundColor=[UIColor whiteColor];
    _userNameShow.font=[UIFont systemFontOfSize:23];
    [self.view addSubview:_userNameShow];
    
    
    _userSex=[[UILabel alloc]initWithFrame:CGRectMake(20,124+50, 130, 50)];
    _userSex.textAlignment=NSTextAlignmentLeft;
    _userSex.text=@"性别:";
    _userSex.backgroundColor=[UIColor clearColor];
    _userSex.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:_userSex];
    
    _userSexShow=[[UILabel alloc]initWithFrame:CGRectMake(120, 124+50, 260, 50)];
    _userSexShow.textAlignment=NSTextAlignmentRight;
    _userSexShow.text=@"";
    _userSexShow.layer.cornerRadius=5;
    _userSexShow.backgroundColor=[UIColor whiteColor];
    _userSexShow.font=[UIFont systemFontOfSize:23];
    [self.view addSubview:_userSexShow];
    
    _userAge=[[UILabel alloc]initWithFrame:CGRectMake(400,124+50, 130, 50)];
    _userAge.textAlignment=NSTextAlignmentLeft;
    _userAge.text=@"年龄:";
    _userAge.backgroundColor=[UIColor clearColor];
    _userAge.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:_userAge];
    
    _userAgeShow=[[UILabel alloc]initWithFrame:CGRectMake(520, 124+50, 230, 50)];
    _userAgeShow.textAlignment=NSTextAlignmentRight;
    _userAgeShow.text=@"";
    _userAgeShow.layer.cornerRadius=5;
    _userAgeShow.backgroundColor=[UIColor whiteColor];
    _userAgeShow.font=[UIFont systemFontOfSize:23];
    [self.view addSubview:_userAgeShow];
    
    
    _useridentifiy=[[UILabel alloc]initWithFrame:CGRectMake(20,194+50, 230, 50)];
    _useridentifiy.textAlignment=NSTextAlignmentLeft;
    _useridentifiy.text=@"证件号:";
    _useridentifiy.backgroundColor=[UIColor clearColor];
    _useridentifiy.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:_useridentifiy];
    
    _useridentifiyShow=[[UILabel alloc]initWithFrame:CGRectMake(120,194+50, 260, 50)];
    _useridentifiyShow.textAlignment=NSTextAlignmentRight;
    _useridentifiyShow.text=@"";
    _useridentifiyShow.layer.cornerRadius=5;
    _useridentifiyShow.backgroundColor=[UIColor whiteColor];
    _useridentifiyShow.font=[UIFont systemFontOfSize:23];
    [self.view addSubview:_useridentifiyShow];
    
    _userEmail=[[UILabel alloc]initWithFrame:CGRectMake(400,194+50, 130, 50)];
    _userEmail.textAlignment=NSTextAlignmentLeft;
    _userEmail.text=@"EMAIL:";
    _userEmail.backgroundColor=[UIColor clearColor];
    _userEmail.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:_userEmail];
    
    _userEmailShow=[[UILabel alloc]initWithFrame:CGRectMake(520,194+50, 230, 50)];
    _userEmailShow.textAlignment=NSTextAlignmentRight;
    _userEmailShow.text=@"";
    _userEmailShow.layer.cornerRadius=5;
    _userEmailShow.backgroundColor=[UIColor whiteColor];
    _userEmailShow.font=[UIFont systemFontOfSize:23];
    [self.view addSubview:_userEmailShow];
    
    
    
    _title=[[UILabel alloc]initWithFrame:CGRectMake(0,260+50, 768,40)];
    _title.textAlignment=NSTextAlignmentCenter;
    _title.text=@"信息列表";
    _title.layer.cornerRadius=5;
    _title.backgroundColor=[UIColor clearColor];
    _title.font=[UIFont systemFontOfSize:18];
    [self.view addSubview:_title];
    
    _lblMessage=[[UILabel alloc]initWithFrame:CGRectMake(20,310+50,728, 300)];
    _lblMessage.textAlignment=NSTextAlignmentCenter;
    _lblMessage.text=@"请输入正确的手机号码后点击确定按钮并等待通讯结束......";
    _lblMessage.lineBreakMode=NSLineBreakByCharWrapping;
    _lblMessage.numberOfLines=3;
    _lblMessage.backgroundColor=[UIColor whiteColor];
    _lblMessage.textColor=[UIColor greenColor];
    _lblMessage.font=[UIFont systemFontOfSize:40];
    [self.view addSubview:_lblMessage];
    
    noCardJuan=[[UILabel alloc]initWithFrame:CGRectMake(20,310+100, 728, 300)];
    noCardJuan.backgroundColor=[UIColor whiteColor];
    noCardJuan.textAlignment=UITextAlignmentCenter;
    noCardJuan.font=[UIFont boldSystemFontOfSize:20];
    noCardJuan.layer.cornerRadius=5;
    noCardJuan.text=@"该会员卡暂无劵可显示...";

    
    
    buttonCancle = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonCancle setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    [buttonCancle setTitle:@"返 回" forState:UIControlStateNormal];
    buttonCancle.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    buttonCancle.tag=2001;
    [buttonCancle addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    buttonCancle.frame=CGRectMake(650, 740-50,80,40);
    [self.view addSubview:buttonCancle];
    
    buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonRed.png"] forState:UIControlStateNormal];
    [buttonSure setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
    [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
    [buttonSure setTitle:@"确 定" forState:UIControlStateNormal];
    buttonSure.tag=2002;
    buttonSure.titleLabel.font=[UIFont fontWithName:@"ArialRoundedMTBold"size:20];
    [buttonSure addTarget:self action:@selector(ButtonQuery:) forControlEvents:UIControlEventTouchUpInside];
    buttonSure.frame=CGRectMake(550, 740-50,80,40);
    [self.view addSubview:buttonSure];
    
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10,50,728-20, 300-65) style:UITableViewStylePlain];
    _tableView.backgroundColor=[UIColor colorWithRed:193/255.0f green:193/255.0f blue:193/255.0f alpha:1];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    
    _tableViewCard=[[UITableView alloc]initWithFrame:CGRectMake(10,50,728-20, 300-65)style:UITableViewStylePlain];
    _tableViewCard.backgroundColor=[UIColor colorWithRed:193/255.0f green:193/255.0f blue:193/255.0f alpha:1];
    _tableViewCard.delegate=self;
    _tableViewCard.dataSource=self;
    
    _vipDict=[[NSMutableDictionary alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refushVipMessage) name:@"refushVipMessage" object:nil];
}

-(void)refushVipMessage
{
    if(akv)
    {
        [showVip removeFromSuperview];
        showVip=nil;
        [akv removeFromSuperview];
        akv=nil;
        akv=[[AKMySegmentAndView alloc]init];
        akv.delegate=self;
        akv.frame=CGRectMake(0, 0, 768, 44);
        //        for (int i=1; i<[akv.subviews count]+1; i++)
        //        {
        //            [[akv.subviews lastObject]removeFromSuperview];
        //            i=1;
        //        }
        [[akv.subviews objectAtIndex:1]removeFromSuperview];
        [self.view addSubview:akv];
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



-(void)ButtonQuery:(UIButton *)btn
{
    if(2001==btn.tag)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(2002==btn.tag)
    {
        if([_phoneNumShow.text length]!=11)
        {
             [self showAlter:@"请输入正确的手机号码"];
        }
        else if([_phoneNumShow.text length]==11)
        {
            AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
            netAccess.delegate=self;
            netAccess.phoneNum=_phoneNumShow.text;
            NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",_phoneNumShow.text,@"phoneNumber", nil];

            [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_GetTrack2"]] andPost:dict andTag:card_GetTrack2];
            [self.view addSubview:_HUD];
            
        }
    }
    else if(2003==btn.tag)
    {
    
        AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
        netAccess.delegate=self;
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",_phoneNumShow.text,@"cardNumber",netAccess.zhangdanId,@"orderId", nil];
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_QueryBalance"]] andPost:dict andTag:card_QueryBalance];
        [self.view addSubview:_HUD];
        
    }
    else if(2004==btn.tag)
    {
        if([_vipDict objectForKey:[AKsNetAccessClass sharedNetAccess].VipCardNum])
        {
            AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
            if([netAccess.yingfuMoney floatValue]>0)
            {
                AKsVipPayViewController *payView=[[AKsVipPayViewController alloc]initWithArray:_dataJuanArray];
                [self.navigationController pushViewController:payView animated:YES];
            }
            else
            {
                bs_dispatch_sync_on_main_thread(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"账单已结算完毕或不存在账单，无需会员卡支付"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }

        }
        else
        {
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"你还没有选择需要消费的会员卡\n请选择后继续操作"
                                                              message:@""
                                                             delegate:nil
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil];
                [alert show];
            });
            
        }

       
    }
    else if(2005==btn.tag)
    {
        if([_vipDict objectForKey:[AKsNetAccessClass sharedNetAccess].VipCardNum])
        {
            NSLog(@"%d",[[AKsNetAccessClass sharedNetAccess].TableNum length]);
            if([[AKsNetAccessClass sharedNetAccess].TableNum length]==11)
            {
                AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
                netAccess.delegate=self;
                NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",netAccess.TableNum,@"tableNum",netAccess.PeopleManNum,@"manCounts",netAccess.PeopleWomanNum,@"womanCounts", nil];
                [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"reserveTableNum"]] andPost:dict andTag:reserveTableNum];
                
            }
            else
            {
                AKOrderRepastViewController *ako=[[AKOrderRepastViewController alloc]init];
                [self.navigationController pushViewController:ako animated:YES];
            }

        }
        else
        {
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"你还没有选择需要消费的会员卡\n请选择后继续操作"
                                                              message:@""
                                                             delegate:nil
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil];
                [alert show];
            });
            
        }
    
    }
    
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
                if([[dict objectForKey:@"zhangdanId"]isEqualToString:[AKsNetAccessClass sharedNetAccess].zhangdanId] && (![[dict objectForKey:@"phoneNum"]isEqualToString:_phoneNumShow.text]))
                {
                    [data delectPhoneNumWhithZhangdanId:[AKsNetAccessClass sharedNetAccess].zhangdanId];
                    [data savePhoneNumWhithZhangdanId:_phoneNumShow.text andZhangDanId:[AKsNetAccessClass sharedNetAccess].zhangdanId];
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
                [data savePhoneNumWhithZhangdanId:_phoneNumShow.text andZhangDanId:[AKsNetAccessClass sharedNetAccess].zhangdanId];
            }
            //    刷新会员信息
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refushVipMessage" object:nil];
            
            _orderArray=[[NSMutableArray alloc]initWithArray:values];
            
            
//            AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
//            netAccess.VipCardNum= lblCardJuanKeShow.text;
            _showMessage=[[AKsNewVipMessageShowView alloc]initWithFrame:CGRectMake(20,310+50,728, 300)];
            _showMessage.delegate=self;
            [_lblMessage removeFromSuperview];
            _lblMessage=nil;
            
            [self.view addSubview:_showMessage];
            [_showMessage addSubview:_tableView];
            
            if ([isChaxun length]==16)
            {
                AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
                netAccess.delegate=self;
                NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",isChaxun,@"cardNumber",netAccess.zhangdanId,@"orderId", nil];
                [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_QueryBalance"]] andPost:dict andTag:card_QueryBalance];
                [self.view addSubview:_HUD];
            }
            else
            {
                if([AKsNetAccessClass sharedNetAccess].isVipShow)
                {
                    [buttonSure setTitle:@"点 菜" forState:UIControlStateNormal];
                    [buttonSure setTitle:@"点 菜" forState:UIControlStateHighlighted];
                    buttonSure.tag=2005;
                }
                else if([Singleton sharedSingleton].isYudian)
                {
                    [buttonSure setTitle:@"点 菜" forState:UIControlStateNormal];
                    [buttonSure setTitle:@"点 菜" forState:UIControlStateHighlighted];
                    buttonSure.tag=2005;
                }
                else
                {
                    [buttonSure setTitle:@"支 付" forState:UIControlStateNormal];
                    [buttonSure setTitle:@"支 付" forState:UIControlStateHighlighted];
                    buttonSure.tag=2004;
                }

            }
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
        
        netAccess.JiFenKeYongMoney=[array objectAtIndex:4];
        netAccess.IntegralOverall=[array objectAtIndex:4];
        netAccess.ChuZhiKeYongMoney=[array objectAtIndex:3];
        netAccess.VipCardNum=[array objectAtIndex:1];
    
        NSArray *VipJuan=[[NSArray alloc]initWithArray:[[array objectAtIndex:7]componentsSeparatedByString:@";"]];
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
        
        
        NSMutableDictionary *vipMessageDict=[[NSMutableDictionary alloc]init];

    
        [vipMessageDict setObject:[array objectAtIndex:1] forKey:@"cardNum"];
        [vipMessageDict setObject:[array objectAtIndex:3] forKey:@"yueMoney"];
        [vipMessageDict setObject:[array objectAtIndex:4] forKey:@"jifenMoney"];
        [vipMessageDict setObject:[array objectAtIndex:6] forKey:@"juanMoney"];
        [vipMessageDict setObject:[array objectAtIndex:8] forKey:@"userName"];
        [vipMessageDict setObject:[array objectAtIndex:9] forKey:@"userSex"];
        [vipMessageDict setObject:[array objectAtIndex:10] forKey:@"userAge"];
        [vipMessageDict setObject:[array objectAtIndex:11] forKey:@"userIndetifiy"];
        [vipMessageDict setObject:[NSString stringWithFormat:@"%@%@",[array objectAtIndex:12],[array objectAtIndex:13]] forKey:@"userEmail"];
        [vipMessageDict setObject:[array objectAtIndex:14] forKey:@"beginTime"];
        [vipMessageDict setObject:_dataJuanArray forKey:@"juanArray"];
        
        _userNameShow.text=[array objectAtIndex:8];
        _userSexShow.text=[array objectAtIndex:9];
        _userAgeShow.text=[array objectAtIndex:10];
        _useridentifiyShow.text=[array objectAtIndex:11];
        _userEmailShow.text=[NSString stringWithFormat:@"%@%@",[array objectAtIndex:12],[array objectAtIndex:13]];
        
        _userNameShow.text=@"李四";
        _userSexShow.text=@"男";
        _userAgeShow.text=@"22";
        _useridentifiyShow.text=@"372928199106150018";
        _userEmailShow.text=@"sundaoran@qq.com";
        
        [_vipDict setObject:vipMessageDict forKey:[array objectAtIndex:1]];
        
    
        AKDataQueryClass *data=[[AKDataQueryClass alloc]init];
        
        [data saveCardNumforVip:netAccess.VipCardNum andPhoneNum:netAccess.phoneNum andzhangdanId:netAccess.zhangdanId andIntegralOverall:netAccess.IntegralOverall];
        
        //    刷新会员信息
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refushVipMessage" object:nil];
        

        if([AKsNetAccessClass sharedNetAccess].isVipShow)
        {
            [buttonSure setTitle:@"点 菜" forState:UIControlStateNormal];
            [buttonSure setTitle:@"点 菜" forState:UIControlStateHighlighted];
            buttonSure.tag=2005;
        }
        else if([Singleton sharedSingleton].isYudian)
        {
            [buttonSure setTitle:@"点 菜" forState:UIControlStateNormal];
            [buttonSure setTitle:@"点 菜" forState:UIControlStateHighlighted];
            buttonSure.tag=2005;
        }
        else
        {
            [buttonSure setTitle:@"支 付" forState:UIControlStateNormal];
            [buttonSure setTitle:@"支 付" forState:UIControlStateHighlighted];
            buttonSure.tag=2004;
        }
        
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
    
    [_tableView reloadData];
    [_tableViewCard reloadData];
}

-(void)HHTreserveTableNumSuccessFormWebService:(NSDictionary *)dict
{
    NSLog(@"=======%@",dict);
    NSArray *array= [self getArrayWithDict:dict andFunction:reserveTableNumName];
    
    NSLog(@"=======%@",array);
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"预定成功：账单号%@\n 等位序号：%@号\n是否预点餐",[array objectAtIndex:1],[array lastObject]]
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"否"
                                                  otherButtonTitles:@"是",nil];
            
            alert.tag=10001;
            [alert show];
            
        });
        [Singleton sharedSingleton].CheckNum=[array objectAtIndex:1];
        [AKsNetAccessClass sharedNetAccess].zhangdanId=[array objectAtIndex:1];
        
    }
    else
    {
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[array lastObject]
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            
        });
    }
    
}

-(void)HHTstartcSuccessFormWebService:(NSDictionary *)dict
{
    NSArray *array=[self getArrayWithDict:dict andFunction:startcName];
    if([[array objectAtIndex:0]isEqualToString:@"0"])
    {
        AKOrderRepastViewController *akor=[[AKOrderRepastViewController alloc]init];
        [self.navigationController pushViewController:akor animated:YES];
        [AKsNetAccessClass sharedNetAccess].zhangdanId=[array lastObject];
        [Singleton sharedSingleton].CheckNum=[array lastObject];
    }
    else
    {
        [self showAlter:[array lastObject]];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10001)
    {
        
        if(buttonIndex==1)
        {
           
            AKOrderRepastViewController *akor=[[AKOrderRepastViewController alloc]init];
            [self.navigationController pushViewController:akor animated:YES];
            [Singleton sharedSingleton].isYudian=YES;
            
        }
    }
}

-(NSArray *)getArrayWithDict:(NSDictionary *)dict andFunction:(NSString *)functionName
{
    NSString *str=[[[dict objectForKey:[NSString stringWithFormat:@"ns:%@Response",functionName]]objectForKey:@"ns:return"]objectForKey:@"text"];
    NSArray *array=[str componentsSeparatedByString:@"@"];
    return array;
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
        return 40;
    }
    else
    {
        return 40;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView==_tableView)
    {
        return 40;
    }
    else
    {
        return 40;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = nil;
    if(tableView==_tableView)
    {
        view=[[UIView alloc]initWithFrame:CGRectMake(0,0 , 708, 40)];
        view.backgroundColor=[UIColor cyanColor];
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 708, 40)];
        label.text=[NSString stringWithFormat:@"     会员卡号                   激活时间             有效期至           储值余额      积分余额"];
        label.textColor=[UIColor blackColor];
        label.font=[UIFont boldSystemFontOfSize:20];
        label.backgroundColor=[UIColor clearColor];
        [view addSubview:label];
    }
    else
    {
        view=[[UIView alloc]initWithFrame:CGRectMake(0,0 , 708, 40)];
        view.backgroundColor=[UIColor cyanColor];
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 708, 40)];
        label.text=[NSString stringWithFormat:@"          劵编码                      劵金额                       劵名称                      劵数量"];
        label.textColor=[UIColor blackColor];
        label.font=[UIFont boldSystemFontOfSize:20];
        label.backgroundColor=[UIColor clearColor];
        [view addSubview:label];

    }
    return view;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView)
    {
        static NSString *cellName=@"cell";
        AKsNewVipMessageShowCell *cell=[_tableView dequeueReusableCellWithIdentifier:cellName];
        if(cell==nil)
        {
            cell=[[AKsNewVipMessageShowCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        NSDictionary *dict=[_vipDict objectForKey:[_orderArray objectAtIndex:indexPath.row]];
        cell.VipNum.text=[_orderArray objectAtIndex:indexPath.row];
        cell.jihuoTime.text=[dict objectForKey:@"beginTime"];
        cell.jifenMoney.text=[dict objectForKey:@"jifenMoney"];
        cell.youxiaoTime.text=@"";
        cell.chuZhiMoney.text=[dict objectForKey:@"yueMoney"];
        if([[_orderArray objectAtIndex:indexPath.row]isEqualToString:[AKsNetAccessClass sharedNetAccess].VipCardNum])
        {
            cell.contentView.backgroundColor=[UIColor grayColor];
        }
        else
        {
            cell.contentView.backgroundColor=[UIColor whiteColor];
        }
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
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((j+1)*182,5, 1, 30)];
            label.backgroundColor=[UIColor blackColor];
            label.alpha=0.5;
            [cell.contentView addSubview:label];
        }
        for(int i=0 ;i<4;i++)
        {
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(i*182,0, 182, 40)];
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
        AKsNetAccessClass *netAccess= [AKsNetAccessClass sharedNetAccess];
        netAccess.delegate=self;
        NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:netAccess.UserId,@"deviceId",netAccess.UserPass,@"userCode",[_orderArray objectAtIndex:indexPath.row],@"cardNumber",netAccess.zhangdanId,@"orderId", nil];
        [netAccess getRequestFromWebService:[NSString stringWithFormat:@"%@",[AKURLString getMainURLWithKey:@"card_QueryBalance"]] andPost:dict andTag:card_QueryBalance];
        [self.view addSubview:_HUD];
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

#pragma mark AKsNewVipMessageShowViewDelegate

-(void)segmentButtonClick:(int)buttonTag
{
    [self dismissView];
    switch (buttonTag)
    {
        case 1000:
            
            [_showMessage addSubview:_tableView];
            break;
        case 1001:
            if([_vipDict objectForKey:[AKsNetAccessClass sharedNetAccess].VipCardNum])
            {
                if([_dataJuanArray count]==0)
                {
                    [_showMessage addSubview:noCardJuan];
                }
                else
                {
                    [_showMessage addSubview:_tableViewCard];
                }
            }
            else
            {
                bs_dispatch_sync_on_main_thread(^{
                    
                    
                    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"你还没有选择需要消费的会员卡\n请选择后继续操作"
                                                                  message:@""
                                                                 delegate:nil
                                                        cancelButtonTitle:@"确定"
                                                        otherButtonTitles:nil];
                    [alert show];
                });

            }
            
            
            break;
        case 1002:
//            消费情况，暂无操作
            break;
        case 1003:
//            交易情况，暂无操作
            break;
            
        default:
            break;
    }

}

-(void)dismissView
{
    if(_tableViewCard && _tableViewCard.superview)
    {
        [_tableViewCard removeFromSuperview];
    }
    if(_tableView && _tableView.superview)
    {
        [_tableView removeFromSuperview];
    }
    if(_lblMessage && _lblMessage.superview)
    {
        [_lblMessage removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
