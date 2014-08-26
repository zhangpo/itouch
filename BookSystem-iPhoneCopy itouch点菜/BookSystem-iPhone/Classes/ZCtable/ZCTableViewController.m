//
//  BSTableViewController.m
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ZCTableViewController.h"
#import "CVLocalizationSetting.h"
#import "BSDataProvider.h"
#import "ZCLogViewController.h"
#import "AppDelegate.h"
#import "ZCCancelTableView.h"
#import "ZCOpenTableView.h"
#import "ZCBSBookViewController.h"
#import "ZCLeftMenuTypeViewController.h"
#import "RNExpandingButtonBar.h"
#import "ZCSwitchTableView.h"

@implementation ZCTableViewController
@synthesize  aryTables,dicListTable,aryResvResult;
@synthesize checkTableInfo;



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.aryTables = nil;
    self.dicListTable = nil;
    self.checkTableInfo = nil;
    self.aryResvResult = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    langSetting = [CVLocalizationSetting sharedInstance];
    UIViewController *tableMenu = [(AppDelegate *)([[UIApplication sharedApplication]delegate]) tableCtrl];
    [tableMenu addBGColor:nil];
    [tableMenu addNavBack];
    [tableMenu setNavTitle:@"查询"];
    
    dSelectedIndex = 0;
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleListTable:) name:msgListTable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenTable:) name:msgOpenTable object:nil];
    //左视图点击之后调用的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeLeftTable:) name:@"ZCChangeLeftTableNotification" object:nil];


    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        scvTables = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height-44-20)];
    }else{
        scvTables = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height-44)];
    }
    scvTables.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    scvTables.delegate = self;
    [self.view addSubview:scvTables];
    [scvTables release];
    
    
    UIImage *image = [UIImage imageNamed:@"red_plus_up.png"];
    UIImage *selectedImage = [UIImage imageNamed:@"red_plus_down.png"];
    UIImage *toggledImage = [UIImage imageNamed:@"red_x_up.png"];
    UIImage *toggledSelectedImage = [UIImage imageNamed:@"red_x_down.png"];
    CGPoint center = CGPointMake(30.0f, ScreenHeight-30-44-20);
    
    CGRect buttonFrame = CGRectMake(0, 0, 50.0f, 50.0f);
    UIButton *change = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [change setFrame:buttonFrame];
    [change setTitle:[langSetting localizedString:@"Change Table"] forState:UIControlStateNormal];
    [change addTarget:self action:@selector(switchTable) forControlEvents:UIControlEventTouchUpInside];
    [change setBackgroundImage:[UIImage imageNamed:@"butBac"] forState:UIControlStateNormal];
    
    UIButton *combine = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [combine setTitle:[langSetting localizedString:@"combine Table"] forState:UIControlStateNormal];
    [combine setFrame:buttonFrame];
    [combine addTarget:self action:@selector(combineTable) forControlEvents:UIControlEventTouchUpInside];
    [combine setBackgroundImage:[UIImage imageNamed:@"butBac"] forState:UIControlStateNormal];
    
    NSArray *buttons = [NSArray arrayWithObjects:change, nil];
    
    RNExpandingButtonBar *bar = [[RNExpandingButtonBar alloc] initWithImage:image selectedImage:selectedImage toggledImage:toggledImage toggledSelectedImage:toggledSelectedImage buttons:buttons center:center];
    [bar setHorizontal:YES];
    [bar setExplode:YES];
    [[self view] addSubview:bar];
    
    
    UIImageView *imgJT = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jiantou"]];
    imgJT.frame = CGRectMake(0, (ScreenHeight-44)/2-140, 10, 180);
    [self.view addSubview:imgJT];
    [imgJT release];
    
    //刷新列表的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableList) name:@"refreshZCTableList" object:nil];
    
    [SVProgressHUD showWithStatus:@"正在获取台位"];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
}

-(void)refreshTableList{
    [SVProgressHUD showWithStatus:@"正在获取台位"];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
}

- (void)loadData{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pListTable_zc:nil];
        BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
        if (bSucceed){
            NSArray *ary = [dict objectForKey:@"Message"];
            
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=0;i<ary.count;i++){
                NSDictionary *dict = [ary objectAtIndex:i];
                
                int status = [[dict objectForKey:@"status"] intValue];
                if (1 || 1==status){
                    [mut addObject:dict];
                }
            }
            self.aryTables = [NSArray arrayWithArray:mut];
            [self showTables:aryTables];
        }
        else{
            sw_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        }
        
        sw_dispatch_sync_on_main_thread(^{
            [SVProgressHUD dismiss];
        });
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


/*
- (void)handleListTable:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    
    BOOL bSucceed = [[info objectForKey:@"Result"] boolValue];
    
    if (bSucceed){
        self.aryTables = [info objectForKey:@"Message"];
        [self performSelectorOnMainThread:@selector(showTables:) withObject:aryTables waitUntilDone:NO];
//        [self showTables:aryTables];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[info objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)handleOpenTable:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    BOOL bSucceed = [[info objectForKey:@"Result"] boolValue];
    
    NSString *title;
    
    if (bSucceed)
        title = [NSString stringWithFormat:@"开台成功，账单流水号为:%@",[info objectForKey:@"Message"]];
    else 
        title = [info objectForKey:@"Message"];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
*/
- (void)showTables:(NSArray *)ary{
    int count = [ary count];
    
    for (UIView *v in scvTables.subviews){
        if ([v isKindOfClass:[ZCTableButton class]])
            [v removeFromSuperview];
    }
    
    for (int i=0;i<count;i++){
        int row = i/2;
        int column = i%2;
        NSDictionary *dic = [ary objectAtIndex:i];
        
        ZCTableButton *btnTable = [ZCTableButton buttonWithType:UIButtonTypeCustom];
//        btnTable.delegate = self;
        btnTable.tag = i;
        btnTable.frame = CGRectMake(160*column, 90*row, 160, 90);
        [btnTable addTarget:self action:@selector(tableClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnTable.layer.cornerRadius = 8;
        btnTable.layer.borderColor = [UIColor whiteColor].CGColor;
        btnTable.layer.borderWidth = 1;
        
        btnTable.tableType = [[dic objectForKey:@"status"] intValue];
        btnTable.tableTitle = [dic objectForKey:@"name"];
        
        [scvTables addSubview:btnTable];
        [scvTables setContentSize:CGSizeMake(320, 10+90*row+64+10+38)];
        
    }
}

#pragma mark - Actions


//并台
-(void)combineTable{
    
}



#pragma mark View's Delegate
- (void)checkTableWithOptions:(NSDictionary *)info{
//    self.checkTableInfo = info;
//    if (self.checkTableInfo){
        [NSThread detachNewThreadSelector:@selector(getTableList:) toTarget:self withObject:info];
        self.dicListTable = info;
//    }
}


- (void)getTableList:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pListTable_zc:info];
    
    BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
    
    if (bSucceed){
        self.aryTables = [dict objectForKey:@"Message"];
        [self performSelectorOnMainThread:@selector(showTables:) withObject:aryTables waitUntilDone:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [pool release];
}


//删除视图
- (void)dismissViews{
//    if (vCheck && vCheck.superview){
//        [vCheck removeFromSuperview];
//        vCheck = nil;
//    }
    if (vOpen && vOpen.superview){
        [vOpen removeFromSuperview];
        vOpen = nil;
    }
    if (vSwitch && vSwitch.superview){
        [vSwitch removeFromSuperview];
        vSwitch = nil;
    }
    if (vCancel && vCancel.superview){
        [vCancel removeFromSuperview];
        vCancel = nil;
    }
}
//开台代理
- (void)openTableWithOptions:(NSDictionary *)info{
    if (info){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
        [dic setObject:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"short"] forKey:@"table"];
        [NSThread detachNewThreadSelector:@selector(openTable:) toTarget:self withObject:dic];
    }
    [self dismissViews];
}

- (void)openTable:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pStart_zc:info];
    BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
    NSString *title;
    
    if (bSucceed) {
        title = [NSString stringWithFormat:@"开台成功，账单流水号为:%@", [dict objectForKey:@"Message"]];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Message"] forKey:@"orderID"];
        [[NSUserDefaults standardUserDefaults] setObject:[info objectForKey:@"table"] forKey:@"tableNum"];
        [[NSUserDefaults standardUserDefaults] setObject:@"ZCopenTable" forKey:@"ZCenterState"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        ZCBSBookViewController *vcBook = [[ZCBSBookViewController alloc] init];
        //初始化左右菜单
//        UIMenuController *menuCtrl = [(AppDelegate *)([[UIApplication sharedApplication] delegate]) menuCtrl];
//        [menuCtrl setRootController:vcBook animated:YES];
        [self.viewController.navigationController pushViewController:vcBook animated:YES];
    }else{
        title = [dict objectForKey:@"Message"];
        [SVProgressHUD showErrorWithStatus:title];
    }
    [pool release];
}

//换台
-(void)switchTable{
    if (vSwitch){
        [vSwitch removeFromSuperview];
        vSwitch = nil;
    }
    vSwitch = [[ZCSwitchTableView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    vSwitch.delegate = self;
    vSwitch.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-130);
    vSwitch.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [self.view addSubview:vSwitch];
    [vSwitch release];
    [UIView animateWithDuration:0.5f animations:^(void) {
        vSwitch.transform = CGAffineTransformIdentity;
    }];
}

- (void)switchTableWithOptions:(NSDictionary *)info{
    if (info){
        [NSThread detachNewThreadSelector:@selector(switchTable:) toTarget:self withObject:info];
    }
    [self dismissViews];
}

- (void)switchTable:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pChangeTable_zc:info];
    
    NSString *msg,*title;
    if ([[dict objectForKey:@"Result"] boolValue]) {
        title = [langSetting localizedString:@"Change Table Succeed"];
        msg = [dict objectForKey:@"Message"];
        [self checkTableWithOptions:self.checkTableInfo];
   }else{
        title = [langSetting localizedString:@"Change Table Failed"];
        msg = [dict objectForKey:@"Message"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [pool release];
}

- (void)cancelTableWithOptions:(NSDictionary *)info{
    if (info){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
        [dic setObject:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"short"] forKey:@"table"];
        
        [NSThread detachNewThreadSelector:@selector(cancelTable:) toTarget:self withObject:dic];
    }
    [self dismissViews];
}

- (void)cancelTable:(NSDictionary *)info{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pOver_zc:info];
        BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
        
        NSString *title,*msg;
        if (bSucceed) {
            title = [langSetting localizedString:@"Cancel Table Succeed"];
            msg = [dict objectForKey:@"Message"];
        }
        else{
            title = [langSetting localizedString:@"Cancel Table Failed"];
            msg = [dict objectForKey:@"Message"];
            
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        alert.tag = 1002;
        [alert show];
    }
}



- (void)releaseSelf{
    [self release];
}

#pragma mark Handle TableButton Click Event
- (void)tableClicked:(ZCTableButton *)btn{
    [self dismissViews];
    dSelectedIndex = btn.tag;
    NSDictionary *info = [self.aryTables objectAtIndex:dSelectedIndex];
//    BSLogViewController *vcLog = [[BSLogViewController alloc] init];
//    vcLog.dicInfo = info;
//    [self.viewController.navigationController pushViewController:vcLog animated:YES];
//    [vcLog release];
//    
//    return;
    
    ZCTableType type = [[info objectForKey:@"status"] intValue];
    UIAlertView *alert;
    switch (type) {
        case ZCTableTypeKongXian:
            if (vOpen){
                [vOpen removeFromSuperview];
                vOpen = nil;
            }
            vOpen = [[ZCOpenTableView alloc] initWithFrame:CGRectMake(0, 0, 280, 215)];
            vOpen.delegate = self;
            vOpen.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-130);
            vOpen.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [self.view addSubview:vOpen];
            [vOpen release];
            [UIView animateWithDuration:0.5f animations:^(void) {
                vOpen.transform = CGAffineTransformIdentity;
            }];
            break;
        case ZCTableTypeKaiTai:
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否要取消开台？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"点餐",@"是", nil];
            alert.tag = kCancelTag;
            [alert show];
            [alert release];
            break;
        
        case ZCTableTypeYuDing:{
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"查询预订信息",@"开台", nil];
            [as showInView:self.view];
            [as release];
        }
            break;
            
        case ZCTableTypeDianCai:{
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"short"],@"table",[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"],@"user",[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"],@"pwd", nil];
            
            ZCLogViewController *vcLog = [[ZCLogViewController alloc] init];
            vcLog.dicInfo = dict;
            [self.viewController.navigationController pushViewController:vcLog animated:YES];
            [vcLog release];
        }
            break;
        
        default:
            break;
    }
}


#pragma mark AlertViewDelegate
- (int)indexOfButtonCoveredPoint:(CGPoint)pt{
    int i = -1;
    
    
    for (ZCTableButton *btn in scvTables.subviews){
        if ([btn isKindOfClass:[ZCTableButton class]]){
      //      CGPoint ptCenter = btn.center;//[btn convertPoint:pt fromView:self.view];
            CGPoint ptCenter = CGPointMake(pt.x, pt.y);//[btn convertPoint:pt fromView:scvTables];
            if ((ptCenter.x-btn.frame.origin.x>=0 && ptCenter.x-btn.frame.origin.x<=btn.frame.size.width) && (ptCenter.y-btn.frame.origin.y>=0 && ptCenter.y-btn.frame.origin.y<=btn.frame.size.height)){
                i = btn.tag;
                break;
            }
        }
    }
    
    return i;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == kCancelTag){
        if (buttonIndex == 2) {
            if (vCancel){
                [vCancel removeFromSuperview];
                vCancel = nil;
            }
            vCancel = [[ZCCancelTableView alloc] initWithFrame:CGRectMake(0, 0, 280, 215)];
            vCancel.delegate = self;
            vCancel.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-130);
            vCancel.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [self.view addSubview:vCancel];
            [vCancel release];
            [UIView animateWithDuration:0.5f animations:^(void) {
                vCancel.transform = CGAffineTransformIdentity;
            }];
        }else if (buttonIndex == 1){
            [[NSUserDefaults standardUserDefaults] setObject:@"ZCorder" forKey:@"ZCenterState"];
            [[NSUserDefaults standardUserDefaults] setObject:[[self.aryTables objectAtIndex:dSelectedIndex] objectForKey:@"short"] forKey:@"tableNum"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
//            ZCBSBookViewController *vcBook = [[ZCBSBookViewController alloc] init];
//            UIViewController *menuCtrl = [(AppDelegate *)([[UIApplication sharedApplication] delegate]) menuCtrl];
//            [menuCtrl setRootController:vcBook animated:YES];
            [self.viewController.navigationController pushViewController:vCancel animated:YES];
        }
        
    }else if (alertView.tag == 1002){
        [self checkTableWithOptions:self.checkTableInfo];
    }
}

#pragma mark -  UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (1==buttonIndex){
        NSDictionary *info = [self.aryTables objectAtIndex:dSelectedIndex];
        

        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"8",@"user",[info objectForKey:@"short"],@"table", nil];
        
        dict = [[BSDataProvider sharedInstance] pListSubscribeOfTable:dict];
        
        NSMutableString *likefood = [NSMutableString string];
        for (int i=0;i<10;i++){
            NSString *likekey = [NSString stringWithFormat:@"f%d",i+1];
            if ([dict objectForKey:likekey]){
                if (9!=i)
                    [likefood appendFormat:@"%@,",[dict objectForKey:likekey]];
                else
                    [likefood appendFormat:@"%@",[dict objectForKey:likekey]];
            }
        }
        if ([likefood length]>0){
            NSMutableDictionary *mutmut = [NSMutableDictionary dictionaryWithDictionary:dict];
            [mutmut setObject:likefood forKey:@"likefood"];
            dict = [NSDictionary dictionaryWithDictionary:mutmut];
        }
        
        
        NSMutableArray *aryKeysValues = [NSMutableArray arrayWithObjects:@"acct",@"账单号码",@"name",@"客户姓名",@"address",@"客户单位",@"mobile",@"手机号码",@"number",@"预定人数",@"time",@"客到时间",@"business",@"客户维护",
                                         @"remark",@"备注信息",@"likefood",@"喜好菜品",@"interest",@"客户禁忌",@"money",@"累计",@"account",@"预定菜品",nil];
        
        
        
        [aryKeysValues addObjectsFromArray:[NSArray arrayWithObjects:@"num",@"菜品数量",@"price",@"菜品总价",nil]];
        NSMutableString *str = [NSMutableString string];
        for (int i=0;i<[aryKeysValues count]/2;i++){
            if ([dict objectForKey:[aryKeysValues objectAtIndex:i*2]])
                [str appendFormat:@"%@:%@\n",[aryKeysValues objectAtIndex:i*2+1],[dict objectForKey:[aryKeysValues objectAtIndex:i*2]]];
        }

        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"预订信息" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectZero];
        lbl.numberOfLines = 0;
        lbl.lineBreakMode = UILineBreakModeWordWrap;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = str;
        [lbl sizeToFit];
        for (UILabel *lbl in alert.subviews){
            if ([lbl isKindOfClass:[UILabel class]] && ![lbl.text isEqualToString:@"预订信息"]){
                lbl.textAlignment = UITextAlignmentLeft;
                lbl.backgroundColor = [UIColor whiteColor];
                lbl.textColor = [UIColor blackColor];
                lbl.font = [UIFont systemFontOfSize:16];
                lbl.shadowColor = nil;
            }
        }
//        [alert addSubview:lbl];
        [lbl release];
        [alert show];
        [alert release];
        
    }else if (2==buttonIndex){
       
    }
}

#pragma mark SearchBar Delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSString *user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    
    self.aryResvResult = [[BSDataProvider sharedInstance] pListResv:[NSDictionary dictionaryWithObjectsAndKeys:user,@"user", nil]];
}

#pragma mark - NSNotification
-(void)ChangeLeftTable:(NSNotification *)notification{
    [self dismissViews];
    int row = [[notification object] integerValue];
//    NSString *row = [notification object];
    switch (row) {
        case 0:
            [self loadData];
            break;
        
        case 1:
            [self loadData:2];
            break;
         
        case 2:
            [self loadData:4];
            break;
            
        case 3:
            [self loadData:1];
            break;
            
        case 4:
            [self loadData:3];
            break;
//
//        case 5:
//            [self loadData:2];
//            break;
            
        default:
            break;
    }
}


- (void)loadData:(NSInteger *)sta{
    int s = sta;
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pListTable_zc:nil];
        
        BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
        
        if (bSucceed){
            NSArray *ary = [dict objectForKey:@"Message"];
            
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=0;i<ary.count;i++){
                NSDictionary *dict = [ary objectAtIndex:i];
                
                int status = [[dict objectForKey:@"status"] intValue];
                if (s==status){
                    [mut addObject:dict];
                }
            }
            self.aryTables = [NSArray arrayWithArray:mut];
            
            [self showTables:aryTables];
        }
        else{
            sw_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
            });
        }
        
        sw_dispatch_sync_on_main_thread(^{
            [SVProgressHUD dismiss];
        });
    }
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    float offset = scrollView.contentOffset.y;
    if (offset < -30) {
        [self refreshTableList];
    }
}

@end
