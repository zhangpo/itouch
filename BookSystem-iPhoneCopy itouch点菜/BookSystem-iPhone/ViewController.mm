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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
    [self addNavButtonWithTitle:userInfo?@"注销当前账户":@"登陆" atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
    [self addNavButtonWithTitle:@"返回" atPosition:SWNavItemPositionLeft action:@selector(backToScan)];
    if (userInfo)
        [self setNavTitle:[userInfo objectForKey:@"username"]];
    
    UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BSLogo.png"]];
    imgv.center = CGPointMake(160, 48+.5f*imgv.image.size.height);
    [self.view addSubview:imgv];
    [imgv release];
    
    lblCommandString = [UILabel createLabelWithFrame:CGRectMake(0, imgv.frame.origin.y+imgv.frame.size.height+10, 320, 16) font:[UIFont systemFontOfSize:16]];
//    lblCommandString.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:lblCommandString];
    lblCommandString.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommandString"];
    
    
//    NSArray *ary = [@"Rank,Search,Statistics,ServerSettings,Calc,Book" componentsSeparatedByString:@","];
//    NSArray *titles = [@"点菜排行榜,查询,营运数据,服务器设置,计算器,点菜" componentsSeparatedByString:@","];
    NSArray *ary = [@"Book,Search,ServerSettings" componentsSeparatedByString:@","];
    NSArray *titles = [@"点菜,查询,服务器设置" componentsSeparatedByString:@","];
    
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

- (void)loginClicked{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
    if (!userInfo){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        alert.delegate = self;
        [alert show];
        [alert release];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
        [self addNavButtonWithTitle:@"登陆" atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
        [self setNavTitle:nil];
    }
}


- (void)buttonClicked:(UIButton *)btn{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"]){
        switch (btn.tag) {
            case 0:{
                BSBookViewController *vcBook = [[BSBookViewController alloc] init];
                [self.navigationController pushViewController:vcBook animated:YES];
                [vcBook release];
                
//                BSStatisticsViewController *vcStatistics = [[BSStatisticsViewController alloc] init];
//                [self.navigationController pushViewController:vcStatistics animated:YES];
//                [vcStatistics release];
            }
                break;
            case 1:{
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:lblCommandString.text?lblCommandString.text:@"1",@"table",[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"],@"user",[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"],@"pwd", nil];
                
                BSLogViewController *vcLog = [[BSLogViewController alloc] init];
                vcLog.dicInfo = dict;
                [self.navigationController pushViewController:vcLog animated:YES];
                [vcLog release];
                 
                /*
                BSTableViewController *vcTable = [[BSTableViewController alloc] init];
                [self.navigationController pushViewController:vcTable animated:YES];
                [vcTable release];
                 */
            }
                break;
            case 2:{
                BSSettingsViewController *vcSettings = [[BSSettingsViewController alloc] init];
                [self.navigationController pushViewController:vcSettings animated:YES];
                [vcSettings release];
                
//                BSStatisticsViewController *vcStatistics = [[BSStatisticsViewController alloc] init];
//                [self.navigationController pushViewController:vcStatistics animated:YES];
//                [vcStatistics release];
            }
                break;
            case 3:{
                BSSettingsViewController *vcSettings = [[BSSettingsViewController alloc] init];
                [self.navigationController pushViewController:vcSettings animated:YES];
                [vcSettings release];
            }
                break;
            case 5:{
                BSBookViewController *vcBook = [[BSBookViewController alloc] init];
                [self.navigationController pushViewController:vcBook animated:YES];
                [vcBook release];
            }
                break;
            default:
                break;
        }
    }else{
        [UIAlertView showAlertWithTitle:nil message:@"请先登录账号" cancelButton:@"确定"];
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
- (void)backToScan{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToScan" object:nil];
}

#pragma mark -  UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]){
        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password", nil] forKey:@"UserInfo"];
        [self addNavButtonWithTitle:@"注销当前账户" atPosition:SWNavItemPositionRight action:@selector(loginClicked)];
        [self setNavTitle:username];
        /*
        if (bExist){
            if (bCorrect)
                [self showDemoView];
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"密码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"用户名不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }*/
    }
}
@end
