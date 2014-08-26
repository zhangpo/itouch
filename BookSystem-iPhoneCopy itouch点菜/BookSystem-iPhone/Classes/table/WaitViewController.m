//
//  WaitViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-26.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "WaitViewController.h"
#import "CVLocalizationSetting.h"
#import "BSDataProvider.h"
#import "WaitTableView.h"
#import "WaitCell.h"
#import "AppDelegate.h"
#import "BSBookViewController.h"
#import "RightOrderViewController.h"
#import "WaitItemViewController.h"
#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface WaitViewController ()

@end

@implementation WaitViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    NSLog(@"aa");
//    [delegate refreshTable];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    langSetting = [CVLocalizationSetting sharedInstance];
    [self addBGColor:nil];
    [self addNavBack];
    [self setNavTitle:[langSetting localizedString:@"Wait"]];
    [self addNavButtonWithTitle:[langSetting localizedString:@"addWait"] atPosition:SWNavItemPositionRight action:@selector(addWait)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        tvWait = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20) style:UITableViewStylePlain];
    }else{
        tvWait = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44) style:UITableViewStylePlain];
    }
    tvWait.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvWait.delegate = self;
    tvWait.dataSource = self;
    [self.view addSubview:tvWait];
    [tvWait release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWaitList) name:@"waitTableTypeNotification" object:nil];
    
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"Being queried"] maskType:SVProgressHUDMaskTypeNone];
    [NSThread detachNewThreadSelector:@selector(getWaitList) toTarget:self withObject:nil];
}

#pragma mark - 网络请求
//获取等位列表
-(void)getWaitList{
    [SVProgressHUD showWithStatus:@""];
    @autoreleasepool {
        NSDictionary *dicWaitList = [[BSDataProvider sharedInstance] getWaitList];
        if ([[dicWaitList objectForKey:@"Result"] boolValue]) {
            aryWaitList = [[dicWaitList objectForKey:@"Message"] retain];
            [tvWait reloadData];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Message"] message:[dicWaitList objectForKey:@"Message"] delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
        [SVProgressHUD dismiss];
    }
}

//获取订单
- (void)loadFood:(NSDictionary *)dicInfo{
    @autoreleasepool {
        orderId = [[dicInfo objectForKey:@"orderId"] retain];
        phone2 = [[dicInfo objectForKey:@"phone"] retain];
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dicResult = [dp queryCompletely:dicInfo];
        if ([[dicResult objectForKey:@"Result"] boolValue]){
            WaitItemViewController *waitCtrl = [[WaitItemViewController alloc] init];
            waitCtrl.aryWaitFood = [dicResult objectForKey:@"Message"];
            waitCtrl.dicInfo = [dicResult objectForKey:@"Info"];
            [self.navigationController pushViewController:waitCtrl animated:YES];
            //            self.aryInfo = [[dict objectForKey:@"Message"] retain];
            //            dicInfoResult = [[dict objectForKey:@"Info"] retain];
            
        }else{
            NSString *title;
            title = [langSetting localizedString:@"change order"];
            //该账单没有预点菜品，是否转为正式单
            langSetting = [CVLocalizationSetting sharedInstance];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"NO"] otherButtonTitles:[langSetting localizedString:@"YES"],nil];
            [alert show];
            alert.tag = 102;
        }
        [SVProgressHUD dismiss];
    }
}

#pragma mark - WaitTableViewDelegate

-(void)dismissViews{
    if (waitView) {
        [waitView removeFromSuperview];
        waitView = nil;
    }else if (changeView){
        [changeView removeFromSuperview];
        changeView = nil;
    }
}
//添加
-(void)addWait{
    if (waitView){
        [waitView removeFromSuperview];
        waitView = nil;
    }
    waitView = [[WaitTableView alloc] initWithFrame:CGRectMake(0, 0, 280, 210)];
    waitView.delegate = self;
    waitView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-120);
    waitView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [self.view addSubview:waitView];
    [waitView release];
    [UIView animateWithDuration:0.5f animations:^(void) {
        waitView.transform = CGAffineTransformIdentity;
    }];
}

- (void)waitTableWithOptions:(NSDictionary *)info{
    if (info) {
        [SVProgressHUD showWithStatus:@""];
        [NSThread detachNewThreadSelector:@selector(addWait:) toTarget:self withObject:info];
    }
    [self dismissViews];
}

-(void)addWait:(NSDictionary *)info{
    @autoreleasepool {
        NSDictionary *dicWaitList = [[BSDataProvider sharedInstance] addWait:info];
        if ([[dicWaitList objectForKey:@"Result"] boolValue]) {
            phone = [[info objectForKey:@"phone"] retain];
            aryPhoneAndOrderId = [[dicWaitList objectForKey:@"soldOutList"] retain];
            NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"WaitSuccess"],[aryPhoneAndOrderId objectAtIndex:0],[aryPhoneAndOrderId objectAtIndex:1]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"WaitSuccess1"] message:str delegate:self cancelButtonTitle:[langSetting localizedString:@"NO"] otherButtonTitles:[langSetting localizedString:@"YES"], nil];
            alert.delegate = self;
            [alert show];
            alert.tag = 101;
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Message"] message:[dicWaitList objectForKey:@"Message"] delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
        [SVProgressHUD dismiss];
    }
}

#pragma mark - changeWaitTableView
-(void)changeWaitTable{
    if (changeView){
        [changeView removeFromSuperview];
        changeView = nil;
    }
    [[NSUserDefaults standardUserDefaults] setValue:phone2 forKey:@"phone2"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    changeView = [[ChangeWaitTableView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
    changeView.delegate = self;
    changeView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-120);
    changeView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [self.view addSubview:changeView];
    [changeView release];
    [UIView animateWithDuration:0.5f animations:^(void) {
        changeView.transform = CGAffineTransformIdentity;
    }];
}

- (void)ChangeWaitTableWithOptions:(NSDictionary *)info{
    if (info) {
        [NSThread detachNewThreadSelector:@selector(changeWaitTable:) toTarget:self withObject:info];
    }
    [self dismissViews];
}

-(void)changeWaitTable:(NSMutableDictionary *)info{
    @autoreleasepool {
        [info setValue:orderId forKey:@"orderID"];
        NSDictionary *dicWaitList = [[BSDataProvider sharedInstance] changeTableNum:info];
        if ([[dicWaitList objectForKey:@"Result"] boolValue]) {
//            [SVProgressHUD showSuccessWithStatus:@"成功！正在刷新"];
//            [SVProgressHUD showWithStatus:[langSetting localizedString:@"SuccessRefresh"] maskType:SVProgressHUDMaskTypeNone];
//            [NSThread detachNewThreadSelector:@selector(getWaitList) toTarget:self withObject:nil];
            [self.navigationController popViewControllerAnimated:YES];
            [delegate refreshTable];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Message"] message:[dicWaitList objectForKey:@"Message"] delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"waitTableCell";
    WaitCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[WaitCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    NSDictionary *dic = [aryWaitList objectAtIndex:indexPath.row];
    cell.dicInfo = dic;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [aryWaitList count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    headerView.backgroundColor = [UIColor colorWithRed:178.0/255.0 green:192.0/255.0 blue:210.0/255.0 alpha:1.0];
    UILabel *lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/2, 20)];
//    lblPhone.textColor = [UIColor whiteColor];
    lblPhone.textAlignment = NSTextAlignmentCenter;
    lblPhone.backgroundColor = [UIColor clearColor];
    lblPhone.text = [langSetting localizedString:@"phone"];
    [headerView addSubview:lblPhone];
    [lblPhone release];
    
    UILabel *lblNum = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2, 0, ScreenWidth/2, 20)];
//    lblNum.textColor = [UIColor whiteColor];
    lblNum.textAlignment = NSTextAlignmentCenter;
    lblNum.backgroundColor = [UIColor clearColor];
    lblNum.text = [langSetting localizedString:@"waitNum"];
    [headerView addSubview:lblNum];
    [lblNum release];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViews];
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"get the order"]];
    //    [SVProgressHUD showWithStatus:@"正在获取账单"];
    NSDictionary *dicInfo = [aryWaitList objectAtIndex:indexPath.row];
    [NSThread detachNewThreadSelector:@selector(loadFood:) toTarget:self withObject:dicInfo];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark - 删除动画效果

//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:YES animated:YES];
    return UITableViewCellEditingStyleDelete;
}

//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:NO animated:YES];
     NSDictionary *dic = [aryWaitList objectAtIndex:indexPath.row];
    NSDictionary *dicResult = [[BSDataProvider sharedInstance] cancelWait:dic];
    if ([[dicResult objectForKey:@"Result"] boolValue]) {
//        [SVProgressHUD showSuccessWithStatus:[dicResult objectForKey:@"Message"]];
//        [SVProgressHUD showWithStatus:[langSetting localizedString:@"Being Delete"] maskType:SVProgressHUDMaskTypeNone];
        //将数组中的数据删除
        [aryWaitList removeObjectAtIndex:indexPath.row];
        
        //将当前cell删除
        [tvWait deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
//        [NSThread detachNewThreadSelector:@selector(getWaitList) toTarget:self withObject:nil];
    }else{
        [SVProgressHUD showErrorWithStatus:[dicResult objectForKey:@"Message"]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSDictionary *dicWaitInfo = [NSDictionary dictionaryWithObjectsAndKeys:[aryPhoneAndOrderId objectAtIndex:0],@"orderID",phone,@"tableNum", nil];
            [[NSUserDefaults standardUserDefaults] setObject:dicWaitInfo forKey:@"dicWaitInfo"];
            [[NSUserDefaults standardUserDefaults] setObject:@"wait" forKey:@"enterState"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            BSBookViewController *vcBook = [[BSBookViewController alloc] init];
            //初始化右视图
            RightOrderViewController *rightOrder = [[RightOrderViewController alloc] init];
//            UIViewController * leftSideDrawerViewController = [[AKOrderLeft alloc] init];
//            
//            UIViewController * centerViewController = [[AKOrderRepastViewController alloc] init];
            MMDrawerController *drawerController=[[MMDrawerController alloc] initWithCenterViewController:vcBook rightDrawerViewController:rightOrder];
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
        }else{
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"SuccessRefresh"] maskType:SVProgressHUDMaskTypeNone];
            [NSThread detachNewThreadSelector:@selector(getWaitList) toTarget:self withObject:nil];
        }
    }else if (alertView.tag == 102){
        if (buttonIndex == 1) {
            [self changeWaitTable];//预定台位转正式台位
        }
    }
}
@end
