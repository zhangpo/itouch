//
//  ViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-17.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "ViewController.h"
#import "BSBookViewController.h"
#import "BSTableViewController.h"
#import "BSStatisticsViewController.h"
#import "BSSettingsViewController.h"
#import "BSLogViewController.h"
#import "LeftMenuTypeViewController.h"
#import "CVLocalizationSetting.h"
#import "BSTableViewController.h"
#import "AppDelegate.h"
#import "LeftTableViewController.h"
#import "BSDataProvider.h"
#import "RightOrderViewController.h"
#import "SearchViewController.h"
#import "ZCTableViewController.h"
#import "ZCBSBookViewController.h"
#import "ZCLeftTableViewController.h"
#import "ZCLeftMenuTypeViewController.h"
#import "ZCLogViewController.h"
#import "BoardViewController.h"
#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    langSetting = [CVLocalizationSetting sharedInstance];
    
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
    [self addNavButtonWithTitle:userInfo?[langSetting localizedString:@"LogOut"]:[langSetting localizedString:@"LogIn"] atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OrderLogin"]) {
        [self addNavButtonWithTitle:[langSetting localizedString:@"Back"] atPosition:SWNavItemPositionLeft action:@selector(backToScan)];
    }

//    [self addNavButtonWithTitle:userInfo?@"注销当前账户":@"登陆" atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OrderLogin"]) {
//        [self addNavButtonWithTitle:@"返回" atPosition:SWNavItemPositionLeft action:@selector(backToScan)];
//    }
    if (userInfo)
        [self setNavTitle:[userInfo objectForKey:@"username"]];
    
    UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BSLogo.png"]];
    imgv.center = CGPointMake(160, 48+.5f*imgv.image.size.height);
    [self.view addSubview:imgv];
    [imgv release];
    //账单号
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OrderLogin"]) {
        lblCommandString = [UILabel createLabelWithFrame:CGRectMake(0, imgv.frame.origin.y+imgv.frame.size.height+10, ScreenWidth, 16) font:[UIFont systemFontOfSize:16]];
        lblCommandString.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:lblCommandString];
        lblCommandString.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommandString"];
        
       
    }
    
//    NSArray *ary = [@"Rank,Search,Statistics,ServerSettings,Calc,Book" componentsSeparatedByString:@","];
//    NSArray *titles = [@"点菜排行榜,查询,营运数据,服务器设置,计算器,点菜" componentsSeparatedByString:@","];
    
//    NSArray *ary = [@"Book,Search,ServerSettings,Statistics" componentsSeparatedByString:@","];
//    NSArray *titles = [@"点菜,查询,服务器设置,营运数据" componentsSeparatedByString:@","];
    
//    NSArray *ary = [@"Book,Search,Table,ServerSettings,Calc" componentsSeparatedByString:@","];
    NSArray *ary = [@"Book,Search,Table,ServerSettings" componentsSeparatedByString:@","];
//    NSArray *titles = [@"点菜,查询,服务器设置,点菜排行" componentsSeparatedByString:@","];
    NSString *OrderDishes = [langSetting localizedString:@"OrderDishes"];
    NSString *Search = [langSetting localizedString:@"Search"];
    NSString *ServerSettings = [langSetting localizedString:@"ServerSettings"];
    NSString *table = [langSetting localizedString:@"Table"];
    NSString *kanban = [langSetting localizedString:@"boark"];
    
//     NSArray *titles = [NSArray arrayWithObjects:OrderDishes,Search,table,ServerSettings,kanban, nil];
    
    NSArray *titles = [NSArray arrayWithObjects:OrderDishes,Search,table,ServerSettings, nil];
    
    for (int i=0;i<ary.count;i++){
        int row = i/4;
        int column = i%4;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(12+75*column, 210+100*row, 64, 64);
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"BSIcon%@.png",i<ary.count?[ary objectAtIndex:i]:@"Empty"]] forState:UIControlStateNormal];
        btn.tag = i;
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *lbl = [UILabel createLabelWithFrame:CGRectMake(8+75*column, 270+100*row, 72, 26) font:[UIFont fontWithName:@"GillSans" size:13] textColor:[UIColor blackColor]];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = i<titles.count?[titles objectAtIndex:i]:nil;
        [self.view addSubview:lbl];
    }
}
//登陆
- (void)loginClicked{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
    if (!userInfo){
#warning 登陆去掉
//        NSDictionary *dic =
//        [NSDictionary dictionaryWithObjectsAndKeys:@"4",@"userCode",@"4",@"userPass",nil];
//        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"UserInfo"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"LogIn"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
        alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        alert.delegate = self;
        alert.tag = 101;
        [alert show];
        [alert release];
    }else{
#warning 暂时注销
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
        if ([sw isEqualToString:@"zc"]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
            [self addNavButtonWithTitle:[langSetting localizedString:@"LogIn"] atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
            [self setNavTitle:nil];
        }else{
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"Logout..."] maskType:SVProgressHUDMaskTypeClear];
            [NSThread detachNewThreadSelector:@selector(_logOut) toTarget:self withObject:nil];
        }
    }
}

//注销
-(void)_logOut{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dicResult =  [dp pLoginOut];
        if ([[dicResult objectForKey:@"Result"] boolValue]) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self addNavButtonWithTitle:[langSetting localizedString:@"LogIn"] atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
            [self setNavTitle:nil];
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus: [dicResult objectForKey:@"Message"]];
        }else{
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus: [dicResult objectForKey:@"Message"]];
        }
    }
}


//快餐点菜
-(void)kc_dianCai{
    [[NSUserDefaults standardUserDefaults] setObject:@"query" forKey:@"enterState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    BSBookViewController *vcBook = [[BSBookViewController alloc] init];
    

    //初始化右视图
    RightOrderViewController *rightOrder = [[RightOrderViewController alloc] init];
    MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:vcBook rightDrawerViewController:rightOrder];
    [drawerController setMaximumRightDrawerWidth:140];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        MMDrawerControllerDrawerVisualStateBlock block;
        block = [[MMExampleDrawerVisualStateManager sharedManager]
                 drawerVisualStateBlockForDrawerSide:drawerSide];
        if(block){
            block(drawerController, drawerSide, percentVisible);
        }
    }];
    [drawerController addNavBack];
    [drawerController addNavButtonWithTitle:[langSetting localizedString:@"Food"] atPosition:SWNavItemPositionRight action:@selector(showOrdered)];
    [drawerController setNavTitle:[langSetting localizedString:@"Menu"]];
    [self.navigationController pushViewController:drawerController animated:YES];
}

//中餐点菜
-(void)zc_dianCai{
    [[NSUserDefaults standardUserDefaults] setObject:@"ZCquery" forKey:@"ZCenterState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    ZCBSBookViewController *vcBook = [[ZCBSBookViewController alloc] init];
    [vcBook addNavBack];
    [vcBook addNavButtonWithTitle:[langSetting localizedString:@"Food"] atPosition:SWNavItemPositionRight action:@selector(showOrdered)];
    [vcBook setNavTitle:[langSetting localizedString:@"Menu"]];
    //初始化左视图显示菜品类别
//    ZCLeftMenuTypeViewController *leftCtrl = [[ZCLeftMenuTypeViewController alloc] init];
    //初始化左右菜单
//    UIViewController *menuCtrl = [(AppDelegate *)([[UIApplication sharedApplication] delegate]) menuCtrl];
//    [self centerViewController:vcBook withLeftSideDrawerViewController:menuCtrl withRightSideDrawerViewController:nil];
//    [menuCtrl setRootController:vcBook animated:YES];
////    menuCtrl.leftViewController = leftCtrl;
    [self.navigationController pushViewController:vcBook animated:YES];
}

//快餐查询
-(void)kc_chaXun{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"OrderLogin"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the ramadhin"]message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tfTable = [alert textFieldAtIndex:0];
        tfTable.keyboardType = UIKeyboardTypeDecimalPad;
        alert.tag = 102;
        [alert show];
        [alert release];
    }else{
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:lblCommandString.text?lblCommandString.text:@"1",@"table", nil];
        SearchViewController *vcLog = [[SearchViewController alloc] init];
        vcLog.dicInfo = dict;
        [self.navigationController pushViewController:vcLog animated:YES];
        [vcLog release];
    }
}

//中餐查询
-(void)zc_chaXun{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"OrderLogin"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the ramadhin"]message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 102;
        [alert show];
    }else{
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:lblCommandString.text?lblCommandString.text:@"1",@"table",[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"],@"user",[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"],@"pwd", nil];
        
        ZCLogViewController *vcLog = [[ZCLogViewController alloc] init];
        vcLog.dicInfo = dict;
        [self.navigationController pushViewController:vcLog animated:YES];
        [vcLog release];
    }
}

//快餐台位
-(void)kc_taiWei{
    [[NSUserDefaults standardUserDefaults] setObject:@"query" forKey:@"enterState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIViewController *table = [[BSTableViewController alloc] init];
    UIViewController *leftTable = [[LeftTableViewController alloc] init];
    
//    UIViewController * leftSideDrawerViewController = [[AKOrderLeft alloc] init];
    
//    UIViewController * centerViewController = [[AKOrderRepastViewController alloc] init];
//    MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:table rightDrawerViewController:leftTable];
    MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:table leftDrawerViewController:leftTable];
    [drawerController setMaximumLeftDrawerWidth:80];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    [drawerController addBGColor:nil];
    [drawerController addNavBack];
    [drawerController setNavTitle:[langSetting localizedString:@"Table Operation"]];
    [self.navigationController pushViewController:drawerController animated:YES];
//    [self centerViewController:table    withLeftSideDrawerViewController:leftTable withRightSideDrawerViewController:nil];
}

//中餐台位
-(void)zc_taiWei{
    ZCTableViewController *table = [[ZCTableViewController alloc] init];
    ZCLeftTableViewController *leftTable = [[ZCLeftTableViewController alloc] init];
//    UIViewController * leftSideDrawerViewController = [[AKOrderLeft alloc] init];
//    
//    UIViewController * centerViewController = [[AKOrderRepastViewController alloc] init];
    MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:table rightDrawerViewController:leftTable];
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
    [drawerController addBGColor:nil];
    [drawerController addNavBack];
    [drawerController setNavTitle:[langSetting localizedString:@"Table Operation"]];
    [self.navigationController pushViewController:drawerController animated:YES];
//    [self centerViewController:table withLeftSideDrawerViewController:leftTable withRightSideDrawerViewController:nil];
}


- (void)buttonClicked:(UIButton *)btn{
        switch (btn.tag) {
            case 0:{
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"]){
                    NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
                    if ([sw isEqualToString:@"zc"]) {
                        [self zc_dianCai];
                    }else{
                        [self kc_dianCai];
                    }
                }else{
                    [UIAlertView showAlertWithTitle:nil message:[langSetting localizedString:@"Please enter the account"] cancelButton:[langSetting localizedString:@"OK"]];
                }
            }
                break;
            case 1:{ //查询
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"]){
                    NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
                    if ([sw isEqualToString:@"zc"]) {
                        [self zc_chaXun];
                    }else{
                        [self kc_chaXun];
                    }
                }else{
                    [UIAlertView showAlertWithTitle:nil message:[langSetting localizedString:@"Please enter the account"] cancelButton:[langSetting localizedString:@"OK"]];
                }
            }
                break;
            case 2:{
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"]){
                    NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
                    if ([sw isEqualToString:@"zc"]) {
                        [self zc_taiWei];
                    }else{
                        [self kc_taiWei];
                    }
                }else{
                    [UIAlertView showAlertWithTitle:nil message:[langSetting localizedString:@"Please enter the account"] cancelButton:[langSetting localizedString:@"OK"]];
                }
            }
                break;
            case 3:{
                BSSettingsViewController *vcSettings = [[BSSettingsViewController alloc] init];
                [self.navigationController pushViewController:vcSettings animated:YES];
                [vcSettings release];
                
            }
                break;
            case 4:{
                NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
                if ([sw isEqualToString:@"zc"]) {
                    BoardViewController *board = [[BoardViewController alloc] init];
                    [self.navigationController pushViewController:board animated:YES];
                    [board release];
                }
            }
                break;
                
            case 5:{
                //                BSStatisticsViewController *vcStatistics = [[BSStatisticsViewController alloc] init];
                //                [self.navigationController pushViewController:vcStatistics animated:YES];
                //                [vcStatistics release];
            }
                break;
            default:
                break;
        }
    
}

- (void)showCommandString{
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommandString"];
    lblCommandString.text = str;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//返回主页面
- (void)backToScan{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToScan" object:nil];
}

#pragma mark -  UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 101) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:[langSetting localizedString:@"OK"]]){
            
            NSString *username = [[alertView textFieldAtIndex:0] text];
            NSString *password = [[alertView textFieldAtIndex:1] text];
            if (username != NULL && ![username isEqualToString:@""] && password != NULL && ![password isEqualToString:@""] && [username length] <=10 && [password length] <= 10) {
                NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
                NSDictionary *dic =   [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password",nil];
                if ([sw isEqualToString:@"zc"]) {//中餐登陆
                    [SVProgressHUD showWithStatus:[langSetting localizedString:@"In the login"] maskType:SVProgressHUDMaskTypeClear];
                    [NSThread detachNewThreadSelector:@selector(_ZClogin:) toTarget:self withObject:dic];
                }else{
                    [SVProgressHUD showWithStatus:[langSetting localizedString:@"In the login"] maskType:SVProgressHUDMaskTypeClear];
                    [NSThread detachNewThreadSelector:@selector(_login:) toTarget:self withObject:dic];
                }
            }else if ([username length] >10 | [password length] > 10){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                               message:@"用戶名密碼不能大於10位"
                                                              delegate:self
                                                     cancelButtonTitle:[langSetting localizedString:@"OK"]
                                                     otherButtonTitles:nil];
                [alert show];
                [alert release];
            }else{
                //@"请输入完整的“员工编号”和“密码”！"  //提示
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[langSetting localizedString:@"prompt"]
                                                               message:[langSetting localizedString:@"number or password"]
                                                              delegate:nil
                                                     cancelButtonTitle:[langSetting localizedString:@"OK"]
                                                     otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
        
    }else if (alertView.tag == 102){ //查询账单
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([buttonTitle isEqualToString:[langSetting localizedString:@"OK"]]){
            UITextField *tf = [alertView textFieldAtIndex:0];
            if (tf.text.length>0 && tf.text.length<10){
                NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
                if ([sw isEqualToString:@"zc"]) {
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tf.text?tf.text:@"1",@"table",[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"],@"user",[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"],@"pwd", nil];
                    
                    ZCLogViewController *vcLog = [[ZCLogViewController alloc] init];
                    vcLog.dicInfo = dict;
                    [self.navigationController pushViewController:vcLog animated:YES];
                    [vcLog release];
                }else{
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tf.text?tf.text:@"1",@"table", nil];
                    SearchViewController *vcLog = [[SearchViewController alloc] init];
                    vcLog.dicInfo = dict;
                    [self.navigationController pushViewController:vcLog animated:YES];
                    [vcLog release];
                }
            }else if (tf.text.length>10){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Maximum input 10"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }

    }else if (alertView.tag == 202){//数据版本更新
        [SVProgressHUD dismiss];
        if (buttonIndex == 1) {
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"Being updated recipe"] maskType:SVProgressHUDMaskTypeClear];//正在更新菜谱
            [NSThread detachNewThreadSelector:@selector(updateData) toTarget:self withObject:nil];
        }
    }
}

//中餐登陆
-(void)_ZClogin:(NSDictionary *)dic{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dicLoginResult = [dp pLoginUser_zc:dic];
        if ([[dicLoginResult objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD showSuccessWithStatus:[langSetting localizedString:@"Login Successed"]];
            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"UserInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self addNavButtonWithTitle:[langSetting localizedString:@"LogOut"] atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
            [self setNavTitle:[dic objectForKey:@"username"]];
        }else{
            [SVProgressHUD showErrorWithStatus:[dicLoginResult objectForKey:@"Message"]];
        }
    }
}


//登陆
-(void)_login:(NSDictionary *)dic{
    @autoreleasepool {
        dicUserCode = [[NSDictionary dictionaryWithDictionary:dic] retain];
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dicLoginResult = [dp pLoginUser:dic];
        if ([[dicLoginResult objectForKey:@"Result"] boolValue]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dicLoginResult objectForKey:@"decimal"] forKey:@"decimal"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (![[dicLoginResult objectForKey:@"posVersion"] isEqualToString:[dicLoginResult objectForKey:@"dataVersion"]]) {
                posVersion = [[dicLoginResult objectForKey:@"posVersion"] retain];
                //数据版本已更新，是否FTP同步数据
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"prompt"] message:[langSetting localizedString:@"Version updated FTP synchronize data"] delegate:self cancelButtonTitle:[langSetting localizedString:@"NO"] otherButtonTitles:[langSetting localizedString:@"YES"], nil];
                [alert show];
                alert.tag = 202;
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:
                 [NSDictionary dictionaryWithObjectsAndKeys:[dicUserCode objectForKey:@"username"],@"username",[dicUserCode objectForKey:@"password"],@"password", nil] forKey:@"UserInfo"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self addNavButtonWithTitle:[langSetting localizedString:@"LogOut"] atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
                //            [self addNavButtonWithTitle:@"注销当前账户" atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
                [self setNavTitle:[dicUserCode objectForKey:@"username"]];
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:[langSetting localizedString:@"Login Successed"]];
            }
        }else{
            [SVProgressHUD dismiss];
            NSString *message = [dicLoginResult objectForKey:@"Message"];
            if (!message) {
                message = [langSetting localizedString:@"Logon failure"];
            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[langSetting localizedString:@"prompt"]
                                                           message:message
                                                          delegate:nil
                                                 cancelButtonTitle:[langSetting localizedString:@"OK"]
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

//更新FTP
- (void)updateData{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dic = [dp updateData];
        
        sw_dispatch_sync_on_main_thread(^{
            if ([[dic objectForKey:@"Result"] boolValue]) {
                [self updateDataVersion];
            }else{
                [NSThread detachNewThreadSelector:@selector(_logOut) toTarget:self withObject:nil];
                [SVProgressHUD dismiss];
                if ([[dic objectForKey:@"Message"] isEqualToString:@"empty"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"更新失敗!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Server timeout"] message:[langSetting localizedString:@"Network link error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }
            
        });
    }
}
//更新版本号
-(void)updateDataVersion{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dic = [dp updateDataVersion:posVersion];
        if ([[dic objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD showSuccessWithStatus:[langSetting localizedString:@"Update complete"]];//更新完成
            [[NSUserDefaults standardUserDefaults] setObject:
             [NSDictionary dictionaryWithObjectsAndKeys:[dicUserCode objectForKey:@"username"],@"username",[dicUserCode objectForKey:@"password"],@"password", nil] forKey:@"UserInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self addNavButtonWithTitle:[langSetting localizedString:@"LogOut"] atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
            //            [self addNavButtonWithTitle:@"注销当前账户" atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
            NSLog(@"%@",[dicUserCode objectForKey:@"username"]);
            [self setNavTitle:[dicUserCode objectForKey:@"username"]];
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:[langSetting localizedString:@"Login Successed"]];
        }else{
            [NSThread detachNewThreadSelector:@selector(_logOut) toTarget:self withObject:nil];
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"Update the version number failed"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

//-(void)centerViewController:(id)centerViewController withLeftSideDrawerViewController:(id)leftViewController withRightSideDrawerViewController:(id)rightViewController
//{
//    UIViewController * center = [[centerViewController alloc] init];
//    MMDrawerController *drawerController=[[MMDrawerController alloc] init];
//    [drawerController setCenterViewController:center];
//    if (!leftViewController&&rightViewController) {
//        UIViewController * rightSideDrawerViewController = [[rightViewController alloc] init];
//        [drawerController setRightDrawerViewController:rightSideDrawerViewController];
//    }else if (!rightViewController&&leftViewController)
//    {
//        UIViewController * leftSideDrawerViewController = [[leftViewController alloc] init];
//        [drawerController setLeftDrawerViewController:leftSideDrawerViewController];
//    }else
//    {
//        UIViewController * leftSideDrawerViewController = [[leftViewController alloc] init];
//        
//        UIViewController * rightSideDrawerViewController = [[rightViewController alloc] init];
//        [drawerController setRightDrawerViewController:rightSideDrawerViewController];
//        [drawerController setLeftDrawerViewController:leftSideDrawerViewController];
//    }
//    [drawerController setMaximumRightDrawerWidth:280.0];
//    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
//    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
//    [drawerController
//     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
//         MMDrawerControllerDrawerVisualStateBlock block;
//         block = [[MMExampleDrawerVisualStateManager sharedManager]
//                  drawerVisualStateBlockForDrawerSide:drawerSide];
//         if(block){
//             block(drawerController, drawerSide, percentVisible);
//         }
//     }];
//    [self.navigationController pushViewController:drawerController animated:YES];
//    
//}

@end
