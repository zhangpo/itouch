//
//  BSSettingsViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-12-1.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "BSSettingsViewController.h"
#import "BSDataProvider.h"
#import "CVLocalizationSetting.h"
#import "BSDataProvider.h"

@interface BSSettingsViewController ()

@end

@implementation BSSettingsViewController
@synthesize dicInfo;

- (void)dealloc{
    self.dicInfo = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    langSetting = langSetting = [CVLocalizationSetting sharedInstance];
    [self setNavTitle:[langSetting localizedString:@"ServerSettings"]];//服务器设置
    [self addBGColor:nil];
    [self addNavBack];
    [self addNavButtonWithTitle:[langSetting localizedString:@"update"] atPosition:SWNavItemPositionRight action:@selector(updateClicked)];//更新

    
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"ServerSettings"];
    if (settings)
        self.dicInfo = [NSMutableDictionary dictionaryWithDictionary:settings];
    else{
        self.dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:[NSDictionary dictionaryWithObjectsAndKeys:[[kPathHeader account] objectForKey:@"username"],@"username",[[kPathHeader account] objectForKey:@"password"],@"password",[kPathHeader hostName],@"ip", nil]
                    forKey:@"ftp"];
        [dicInfo setObject:[NSDictionary dictionaryWithObjectsAndKeys:[[kSocketServer componentsSeparatedByString:@":"] objectAtIndex:0],@"ip",[[kSocketServer componentsSeparatedByString:@":"] objectAtIndex:1],@"port", nil]
                    forKey:@"api"];
        
        [[NSUserDefaults standardUserDefaults] setObject:dicInfo forKey:@"ServerSettings"];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        tvSettings = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20) style:UITableViewStyleGrouped];
    }else{
        tvSettings = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44) style:UITableViewStyleGrouped];
    }
    tvSettings.delegate = self;
    tvSettings.dataSource = self;
    tvSettings.backgroundView = [[[UIView alloc] init] autorelease];
    tvSettings.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tvSettings];
    [tvSettings release];
}

- (void)updateClicked{
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"Being updated recipe"] maskType:SVProgressHUDMaskTypeClear];//正在更新菜谱
    
    [NSThread detachNewThreadSelector:@selector(updateData) toTarget:self withObject:nil];
}

- (void)updateData{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dic = [dp updateData];
        
        sw_dispatch_sync_on_main_thread(^{
            if ([[dic objectForKey:@"Result"] boolValue]) {
                [SVProgressHUD showSuccessWithStatus:[langSetting localizedString:@"Update complete"]];//更新完成
            }else{
                if ([[dic objectForKey:@"Message"] isEqualToString:@"empty"]) {
                    [SVProgressHUD dismiss];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"更新失敗!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }else{
                    [SVProgressHUD dismiss];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Server timeout"] message:[langSetting localizedString:@"Network link error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }
            
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"SettingsIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSString *str1,*str2;
    NSDictionary *info = [dicInfo objectForKey:0==indexPath.section?@"ftp":@"api"];
    NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:
                    str1 = [langSetting localizedString:@"Service address"];
                    //str1 = @"服务器地址";
                    str2 = [info objectForKey:@"ip"];
                    break;
                case 1:
                    str1 = [langSetting localizedString:@"UserName"];
//                    str1 = @"用户名";
                    str2 = [info objectForKey:@"username"];
                    break;
                case 2:
                    str1 = [langSetting localizedString:@"PassWord"];
//                    str1 = @"密码";
                    str2 = [info objectForKey:@"password"];
                default:
                    break;
            }
        }
            break;
        case 1:{
            switch (indexPath.row) {
                case 0:
                    str1 = [langSetting localizedString:@"Service address"];
//                    str1 = @"服务器地址";
                    str2 = [info objectForKey:@"ip"];
                    break;
                case 1:
                    str1 = [langSetting localizedString:@"Port"];
//                    str1 = @"端口号";
                    str2 = [info objectForKey:@"port"];
                    break;
                default:
                    break;
            }
        }
            break;
            
        case 2:{
            switch (indexPath.row) {
                case 0:
                    if ([sw isEqualToString:@"zc"]) {
                        str1 = [langSetting localizedString:@"equipment code"];
                        str2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"equipment"];
                    }else{
                        str1 = [langSetting localizedString:@"physical code"];
                        NSString *deviceID = [NSString performSelector:@selector(UUIDString)];
                        str2 = deviceID;
                    }
                    break;
                case 1:
                    str1 = [langSetting localizedString:@"equipment code"];
                    str2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"equipment"];
                    break;
                case 2:
                    str1 = [langSetting localizedString:@"Equipment registration"];
                    str2 = @"";
                default:
                    break;
            }
        }
            break;
            
        case 3:{
            switch (indexPath.row) {
                case 0: //sound
                    str1 = [langSetting localizedString:@"sound"];
//                    str1 = @"是否需要发送";
                    str2 = nil;
                    break;
                    
                default:
                    break;
            }
        }
            break;

            break;
        default:
            break;
    }
    
    
    cell.textLabel.text = str1;
    cell.detailTextLabel.text = str2;
    
    if (3==indexPath.section){
        UISwitch *sw = [[UISwitch alloc] init];
        [sw sizeToFit];
        [sw addTarget:self action:@selector(skipClicked:) forControlEvents:UIControlEventValueChanged];
//        sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"SkipSend"];
        sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
        cell.accessoryView = sw;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
        //防止重用,判断记录的_index是否和当前的row相同
//    if (_index == indexPath.row && 5==indexPath.section) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
    if (section == 0) {
        return 3;
    }else if (section == 1){
        return 2;
    }else if (![sw isEqualToString:@"zc"] && section == 2){
        return 3;
    }else if ([sw isEqualToString:@"zc"] && section == 2){
        return 1;
    }else if (section == 3){
        return 1;
    }
    return 1;
   }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return 0==section?@"FTP":(1==section?@"API":(2==section?@"Number":@"SOUND"));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     NSString *sw = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
    if (2!=indexPath.section && 3!=indexPath.section && 4!=indexPath.section){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the modify the content"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入修改内容" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 100*indexPath.section+indexPath.row;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.delegate = self;
        [alert show];
        [alert release];
    }else if (2 == indexPath.section){
        if ([sw isEqualToString:@"zc"]) {
            if (indexPath.row == 0 && 2 == indexPath.section){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"equipment number"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
                alert.tag = 1021;
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                alert.delegate = self;
                [alert show];
                [alert release];
            }
        }else{
            if (indexPath.row == 2) {
                [SVProgressHUD showWithStatus:@"正在注冊設備..."];
                [NSThread detachNewThreadSelector:@selector(_registerDevice) toTarget:self withObject:nil];
            }else if (indexPath.row == 1 && 2 == indexPath.section){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"equipment number"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
                alert.tag = 1021;
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                alert.delegate = self;
                [alert show];
                [alert release];
            }
        }
        
    }
}

//注册设备
- (void)_registerDevice{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dic = [dp registerDeviceId];
        if ([[dic objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD showSuccessWithStatus:[dic objectForKey:@"Message"]];
        }else{
//            [SVProgressHUD showErrorWithStatus:[langSetting localizedString:@"Registration failed"]];
            [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"Message"]];
        }
    }
}

//判断是否开启发送
- (void)skipClicked:(UISwitch *)sw{
     NSUserDefaults *myUserDefaults = [NSUserDefaults standardUserDefaults];
    [myUserDefaults setBool:sw.isOn forKey:@"sound"];
    [myUserDefaults synchronize];
}

#pragma mark -  UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 108) {
        exit(0);//退出应用程序
        return;
    }
    if (alertView.tag ==1021 && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:[langSetting localizedString:@"OK"]]) {
        NSLog(@"%@",[[alertView textFieldAtIndex:0] text]);
        if ([[[alertView textFieldAtIndex:0] text] length] > 15) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:@"設備編號不能大於15位" delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[[alertView textFieldAtIndex:0] text] forKey:@"equipment"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [tvSettings reloadData];
        return;
    }
    int section = alertView.tag/100;
    int row = alertView.tag%100;
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:[langSetting localizedString:@"OK"]]){
        NSString *text = [[alertView textFieldAtIndex:0] text];
        
        if (text.length>0){
            NSString *key = nil;
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[dicInfo objectForKey:0==section?@"ftp":@"api"]];
            switch (section) {
                case 0:{
                    switch (row) {
                        case 0:
                            key = @"ip";
                            break;
                        case 1:
                            key = @"username";
                            break;
                        case 2:
                            key = @"password";
                        default:
                            break;
                    }
                }
                    break;
                case 1:{
                    switch (row) {
                        case 0:
                            key = @"ip";
                            break;
                        case 1:
                            key = @"port";
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
            
            [info setObject:text forKey:key];
            [dicInfo setObject:info forKey:0==section?@"ftp":@"api"];
            
            [[NSUserDefaults standardUserDefaults] setObject:dicInfo forKey:@"ServerSettings"];
            
            [tvSettings reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
    }else{
        [tvSettings deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:YES];
    }
}
@end
