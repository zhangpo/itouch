//
//  AKsVipViewController.m
//  BookSystem
//
//  Created by sundaoran on 13-12-4.
//
//

#import "AKsVipViewController.h"
#import "AKsVipPayViewController.h"
#import "PaymentSelect.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "MMDrawerController.h"
#import "AKOrderLeft.h"
#import "AKsIsVipShowView.h"


@interface AKsVipViewController ()

@end

@implementation AKsVipViewController
{
    UITextField  *_cardTf;
    AKsIsVipShowView *showVip;
    AKMySegmentAndView *akv;
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
    AKsVipCardQueryView *akcard=[[AKsVipCardQueryView alloc]init];
    akcard.frame=CGRectMake(0, 0, 768, 1024);
    akcard.delegate=self;
    [self.view addSubview:akcard];
    [self.view sendSubviewToBack:akcard];
    
    
    UIControl *control=[[UIControl alloc]initWithFrame:self.view.bounds];
    [control addTarget:self action:@selector(ControlClick) forControlEvents:UIControlEventTouchUpInside];
    [akcard addSubview:control];
    [akcard sendSubviewToBack:control];
    
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

-(void)ControlClick
{
    [_cardTf resignFirstResponder];
}

-(void)controlClick:(UITextField *)cardTf
{
    _cardTf=cardTf;
}

#pragma mark ---AKsVipCardQueryDelegate
-(void)VipCardCancle
{
    //    [AKsNetAccessClass sharedNetAccess].IntegralOverall=@"";
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)ClickPayButton:(NSMutableArray *)juanArray
{
    AKsNetAccessClass *netAccess=[AKsNetAccessClass sharedNetAccess];
    if([netAccess.yingfuMoney floatValue]>0)
    {
        AKsVipPayViewController *payView=[[AKsVipPayViewController alloc]initWithArray:juanArray];
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

-(void)ClickDiancaiView
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
//        UIViewController * leftSideDrawerViewController = [[AKOrderLeft alloc] init];
//        
//        UIViewController * centerViewController = [[AKOrderRepastViewController alloc] init];
//        
//        //    UIViewController * rightSideDrawerViewController = [[RightViewController alloc] init];
//        
//        MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:centerViewController rightDrawerViewController:leftSideDrawerViewController];
//        [drawerController setMaximumRightDrawerWidth:280.0];
//        [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
//        [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
//        
//        [drawerController
//         setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
//             MMDrawerControllerDrawerVisualStateBlock block;
//             block = [[MMExampleDrawerVisualStateManager sharedManager]
//                      drawerVisualStateBlockForDrawerSide:drawerSide];
//             if(block){
//                 block(drawerController, drawerSide, percentVisible);
//             }
//         }];
//        [self.navigationController pushViewController:drawerController animated:YES];    }
        
        
//         跳转，无抽屉
        AKOrderRepastViewController *ako=[[AKOrderRepastViewController alloc]init];
        [self.navigationController pushViewController:ako animated:YES];
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

//链接失败
-(void)failedFromWebServie
{
    
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                  message:@"网络连接失败，请检查网络！"
                                                 delegate:nil
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil];
    [alert show];
    
    //    [self showAlterDelegate:@"网络连接失败，请检查网络！"];
}


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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10001)
    {
        
        if(buttonIndex==1)
        {
            UIViewController * leftSideDrawerViewController = [[AKOrderLeft alloc] init];
            
            UIViewController * centerViewController = [[AKOrderRepastViewController alloc] init];
            
            //    UIViewController * rightSideDrawerViewController = [[RightViewController alloc] init];
            
            MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:centerViewController rightDrawerViewController:leftSideDrawerViewController];
            [drawerController setMaximumRightDrawerWidth:280.0];
            [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
            [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
            
            [drawerController
             setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
                 MMDrawerControllerDrawerVisualStateBlock block;
                 block = [[MMExampleDrawerVisualStateManager sharedManager]
                          drawerVisualStateBlockForDrawerSide:drawerSide];
                 if(block){
                     block(drawerController, drawerSide, percentVisible);
                 }
             }];
            [self.navigationController pushViewController:drawerController animated:YES];
            
            [Singleton sharedSingleton].isYudian=YES;
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
