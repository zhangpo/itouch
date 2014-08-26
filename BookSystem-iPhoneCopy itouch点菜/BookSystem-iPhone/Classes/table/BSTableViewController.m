//
//  BSTableViewController.m
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSTableViewController.h"
#import "CVLocalizationSetting.h"
#import "BSDataProvider.h"
#import "BSLogViewController.h"
#import "AppDelegate.h"
#import "BSCancelTableView.h"
#import "BSOpenTableView.h"
#import "BSBookViewController.h"
#import "LeftMenuTypeViewController.h"
#import "BSSwitchTableView.h"
#import "RNExpandingButtonBar.h"
#import "SearchCoreManager.h"
#import "RightOrderViewController.h"
#import "WaitViewController.h"

@implementation BSTableViewController
@synthesize  aryTables,dicListTable,aryResvResult,aryTableResult;
@synthesize checkTableInfo,searchByName,contactDic;



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
    tableMenu = [(AppDelegate *)([[UIApplication sharedApplication] delegate]) tableCtrl];
    [tableMenu addBGColor:nil];
    [tableMenu addNavBack];
    [tableMenu setNavTitle:[langSetting localizedString:@"Table Operation"]];
    
    dSelectedIndex = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleListTable:) name:msgListTable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenTable:) name:msgOpenTable object:nil];
    //左视图点击之后调用的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeLeftTable:) name:@"ChangeLeftTableNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:@"openTableTypeNotification" object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        scvTables = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20)];
    }else{
        scvTables = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44)];
    }
//    scvTables.backgroundColor= [UIColor clearColor];
    scvTables.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    scvTables.delegate = self;
    [self.view addSubview:scvTables];
    [scvTables release];
    
    UIImageView *imgJT = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jiantou"]];
    imgJT.frame = CGRectMake(0, (ScreenHeight-44)/2-140, 10, 180);
    [self.view addSubview:imgJT];
    [imgJT release];
    
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
    
    UIButton *equipotential = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [equipotential setTitle:[langSetting localizedString:@"equipotential"] forState:UIControlStateNormal];
    [equipotential addTarget:self action:@selector(waitTable) forControlEvents:UIControlEventTouchUpInside];
    [equipotential setBackgroundImage:[UIImage imageNamed:@"butBac"] forState:UIControlStateNormal];
    [equipotential setFrame: CGRectMake(0, 0, 50.0f, 50.0f)];
    NSArray *buttons = [NSArray arrayWithObjects:change, combine,equipotential, nil];
    
    RNExpandingButtonBar *bar = [[RNExpandingButtonBar alloc] initWithImage:image selectedImage:selectedImage toggledImage:toggledImage toggledSelectedImage:toggledSelectedImage buttons:buttons center:center];
    [bar setHorizontal:YES];
    [bar setExplode:YES];
    [[self view] addSubview:bar];
    
    //搜索的背景视图
    imgv = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imgv setImage:[UIImage imageNamed:@"padbg.png"]];
    imgv.userInteractionEnabled = YES;
    imgv.frame = CGRectMake(0, 0, ScreenWidth, 38);
//    imgv.hidden = YES;
    [self.view addSubview:imgv];
    [imgv release];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"paddown.png"] forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.frame = CGRectMake(280, 3, 35, 30);
    [btn addTarget:self action:@selector(updownClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgv addSubview:btn];
    
    searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, 38.0f)] autorelease];
    searchBar.frame = CGRectMake(0, 3, 275, 30);
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeDefault;
	searchBar.backgroundColor=[UIColor clearColor];
    [searchBar setBackgroundImage:[UIImage imageNamed:@"padbg.png"]];
//    searchBar.backgroundColor = [UIColor clearColor];
	searchBar.translucent=YES;
	searchBar.placeholder=@"搜索";
	searchBar.delegate = self;
	searchBar.barStyle=UIBarStyleDefault;
    [imgv addSubview:searchBar];
    
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"Get ramadhin"] maskType:SVProgressHUDMaskTypeClear];//正在获取台位
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SearchCoreManager share] Reset];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
}
- (void)loadData{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pListTable:nil];
        if ([[dict objectForKey:@"Result"] boolValue]){
            NSArray *ary = [dict objectForKey:@"Message"];
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=0;i<ary.count;i++){
                NSDictionary *dict = [ary objectAtIndex:i];
                int status = [[dict objectForKey:@"status"] intValue];
                if (1 || 1==status){
                    [mut addObject:dict];
                }
            }
            NSArray *aryPX = [NSArray arrayWithArray:mut];
            self.aryTables = [aryPX sortedArrayUsingFunction:intSort3 context:NULL];
            self.aryTableResult = [self.aryTables retain];
            [self showTables:aryTables];
            [self.aryTables retain];
            [self serach];
        }else{
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Query Table Fail"] message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
            });
        }
        [SVProgressHUD dismiss];
    }
}
//刷新Table列表
-(void)refreshTable{
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"Get ramadhin"] maskType:SVProgressHUDMaskTypeClear];//正在获取台位
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
}
-(void)serach{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.contactDic = dic;
    [dic release];
    
    NSMutableArray *nameIDArray = [[NSMutableArray alloc] init];
    self.searchByName = nameIDArray;
    [nameIDArray release];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    searchByResult = resultArray;
    [resultArray release];
    
    NSNumber *localID = 0;
    NSString *name,*itcope;
    int i = 0;
    for (NSMutableDictionary *dic in self.aryTables) {
        localID = [NSNumber numberWithInt:i];
        name = [dic objectForKey:@"tablename"];
        itcope = [dic objectForKey:@"name"];
        [[SearchCoreManager share] AddContact:localID name:name phone:nil];
        [self.contactDic setObject:itcope forKey:localID];
        i++;
    }
}

//排序方法：
NSInteger intSort3(id num1,id num2,void *context){
    int v1 = [[(NSDictionary *)num1 objectForKey:@"name"] intValue];
    int v2 = [[(NSDictionary *)num2 objectForKey:@"name"] intValue];
    
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

//加载中餐餐桌
- (void)loadData_zhongcan{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pListTable:nil];
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
            NSArray *aryPX = [NSArray arrayWithArray:mut];
            self.aryTables = [aryPX sortedArrayUsingFunction:intSort3 context:NULL];
            
            [self showTables:aryTables];
        }
        else{
            sw_dispatch_sync_on_main_thread(^{
                //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                //                [alert show];
                //                [alert release];
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



- (void)handleListTable:(NSNotification *)notification{
    NSDictionary *info = [notification userInfo];
    
    BOOL bSucceed = [[info objectForKey:@"Result"] boolValue];
    
    if (bSucceed){
//        self.aryTables = [info objectForKey:@"Message"];
//        [self performSelectorOnMainThread:@selector(showTables:) withObject:aryTables waitUntilDone:NO];
//        [self showTables:aryTables];
    }
    else{
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[info objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
    }
}

/*
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
        if ([v isKindOfClass:[BSTableButton class]])
            [v removeFromSuperview];
    }
    
    for (int i=0;i<count;i++){
        int row = i/2;
        int column = i%2;
        NSDictionary *dic = [ary objectAtIndex:i];
        
        BSTableButton *btnTable = [BSTableButton buttonWithType:UIButtonTypeCustom];
//        btnTable.delegate = self;
        btnTable.tag = i;
        btnTable.frame = CGRectMake(160*column, 90*row+38, 160, 90);
        [btnTable addTarget:self action:@selector(tableClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnTable.layer.cornerRadius = 8;
        btnTable.layer.borderColor = [UIColor whiteColor].CGColor;
        btnTable.layer.borderWidth = 1;
        
        btnTable.tableType = [[dic objectForKey:@"status"] intValue];
        btnTable.tableTitle = [dic objectForKey:@"tablename"];
        btnTable.people = [dic objectForKey:@"person"];
        
        [scvTables addSubview:btnTable];
        
        [scvTables setContentSize:CGSizeMake(320, 10+90*row+64+10+38+50)];
        
    }
}

//搜索框旁边的隐藏键盘按钮
- (void)updownClicked:(UIButton *)btn{
    [searchBar resignFirstResponder];
}
//- (void)showTables:(NSArray *)ary{
//    int count = [ary count];
//    
//    for (UIView *v in scvTables.subviews){
//        if ([v isKindOfClass:[BSTableButton class]])
//            [v removeFromSuperview];
//    }
//    
//    for (int i=0;i<count;i++){
//        int row = i/4;
//        int column = i%4;
//        NSDictionary *dic = [ary objectAtIndex:i];
//        
//        BSTableButton *btnTable = [BSTableButton buttonWithType:UIButtonTypeCustom];
//        //        btnTable.delegate = self;
//        btnTable.tag = i;
//        btnTable.frame = CGRectMake(12+75*column, 10+80*row, 64, 64);
//        [btnTable addTarget:self action:@selector(tableClicked:) forControlEvents:UIControlEventTouchUpInside];
//        btnTable.layer.cornerRadius = 8;
//        btnTable.layer.borderColor = [UIColor whiteColor].CGColor;
//        btnTable.layer.borderWidth = 1;
//        
//        btnTable.tableTitle = [dic objectForKey:@"name"];
//        btnTable.tableType = [[dic objectForKey:@"status"] intValue];
//        
//        [scvTables addSubview:btnTable];
//        
//        [scvTables setContentSize:CGSizeMake(320, 10+80*row+64+10)];
//        
//    }
//}





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
    NSDictionary *dict = [dp pListTable:info];
    
    if ([[dict objectForKey:@"Message"] count] > 0){
        NSArray *ary = [dict objectForKey:@"Message"];
        NSMutableArray *mut = [NSMutableArray array];
        for (int i=0;i<ary.count;i++){
            NSDictionary *dict = [ary objectAtIndex:i];
            [mut addObject:dict];
        }
        NSArray *aryPX = [NSArray arrayWithArray:mut];
        self.aryTables = [[aryPX sortedArrayUsingFunction:intSort3 context:NULL] retain];
        
        [self showTables:aryTables];
    }else{
        sw_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Query Table Fail"] message:[dict objectForKey:@"MessageFail"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"]otherButtonTitles:nil];
            [alert show];
        });
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
    if (vCombine && vCombine.superview) {
        [vCombine removeFromSuperview];
        vCombine = nil;
    }
}
//开台代理
- (void)openTableWithOptions:(NSDictionary *)info{
    if (info){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
        [dic setObject:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"] forKey:@"tableNum"];
        [dic setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"]  forKey:@"userCode"];
        [SVProgressHUD showWithStatus:@"" maskType:SVProgressHUDMaskTypeClear];
        [NSThread detachNewThreadSelector:@selector(openTable:) toTarget:self withObject:dic];
    }
    [self dismissViews];
}

- (void)openTable:(NSDictionary *)info{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pStart:info];
        NSString *title;
        if ([[dict objectForKey:@"Result"] boolValue]) {
            //        [scvTables reloadInputViews];
            title = [NSString stringWithFormat:[langSetting localizedString:@"Open Table success! OrderID"], [dict objectForKey:@"Message"]];//开台成功，账单流水号为
//            [self checkTableWithOptions:self.checkTableInfo];
            
            [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Message"] forKey:@"orderID"];
            [[NSUserDefaults standardUserDefaults] setObject:[info objectForKey:@"tableNum"] forKey:@"tableNum"];
            [[NSUserDefaults standardUserDefaults] setObject:@"openTable" forKey:@"enterState"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            bs_dispatch_sync_on_main_thread(^{
                [self _order];
            });
        }else{
            title = [dict objectForKey:@"Message"];
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
            
        }
    }
}

//换台
-(void)switchTable{
    if (vSwitch){
        [vSwitch removeFromSuperview];
        vSwitch = nil;
    }
    vSwitch = [[BSSwitchTableView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
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
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pChangeTable:info];
        NSString *msg,*title;
        if ([[dict objectForKey:@"Result"] boolValue]) {
            title = [langSetting localizedString:@"Change Table Succeed"];
            msg = [dict objectForKey:@"Message"];
            [self checkTableWithOptions:self.checkTableInfo];
        }
        else{
            title = [langSetting localizedString:@"Change Table Failed"];
            msg = [dict objectForKey:@"Message"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
    }
}

//并台
-(void)combineTable{
    if (vCombine){
        [vCombine removeFromSuperview];
        vCombine = nil;
    }
    vCombine = [[BSCombineTableView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    vCombine.delegate = self;
    vCombine.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-130);
    vCombine.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [self.view addSubview:vCombine];
    [vCombine release];
    [UIView animateWithDuration:0.5f animations:^(void) {
        vCombine.transform = CGAffineTransformIdentity;
    }];
}

-(void)combineTableWithOptions:(NSDictionary *)info{
    if (info){
        [NSThread detachNewThreadSelector:@selector(combineTable:) toTarget:self withObject:info];
    }
    [self dismissViews];
    
}

-(void)combineTable:(NSDictionary *)info{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pCombineTable:info];
        NSString *msg,*title;
        if ([[dict objectForKey:@"Result"] boolValue]) {
            title = [langSetting localizedString:@"combine Table Succeed"];
            msg = [dict objectForKey:@"Message"];
            [self checkTableWithOptions:self.checkTableInfo];
        }
        else{
            title = [langSetting localizedString:@"combine Table Failed"];
            msg = [dict objectForKey:@"Message"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
    }
}

- (void)cancelTableWithOptions:(NSDictionary *)info{
    /*中餐
    if (info){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
        [dic setObject:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"] forKey:@"table"];
        
        [NSThread detachNewThreadSelector:@selector(cancelTable:) toTarget:self withObject:dic];
    }
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setObject:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"] forKey:@"table"];
    
    [NSThread detachNewThreadSelector:@selector(cancelTable:) toTarget:self withObject:dic];
    
    [self dismissViews];
}

- (void)cancelTable:(NSDictionary *)info{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pOver:info];
        
        BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
        
        NSString *title,*msg;
        if (bSucceed) {
            title = [langSetting localizedString:@"Cancel Table Succeed"];
            msg = [dict objectForKey:@"Message"];
            
            [self checkTableWithOptions:self.checkTableInfo];
        }
        else{
            title = [langSetting localizedString:@"Cancel Table Failed"];
            msg = [dict objectForKey:@"Message"];
            
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
    }
}

//等位预点
-(void)waitTable{
    WaitViewController *ctrlWait = [[WaitViewController alloc] init];
    [self.viewController.navigationController pushViewController:ctrlWait animated:YES];
    ctrlWait.delegate = self;
    [ctrlWait release];
}

- (void)releaseSelf{
    [self release];
}

#pragma mark Handle TableButton Click Event
//点击不同状态的台位的事件处理
- (void)tableClicked:(BSTableButton *)btn{
    [self dismissViews];
    [searchBar resignFirstResponder];
    dSelectedIndex = btn.tag;
    NSDictionary *info = [self.aryTables objectAtIndex:dSelectedIndex];

    BSTableType type = [[info objectForKey:@"status"] intValue];
    UIAlertView *alert;
    switch (type) {
        case BSTableTypeKongXian:
            if (vOpen){
                [vOpen removeFromSuperview];
                vOpen = nil;
            }
            vOpen = [[BSOpenTableView alloc] initWithFrame:CGRectMake(0, 0, 275, 200)];
            vOpen.delegate = self;
            vOpen.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-130);
            vOpen.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [self.view addSubview:vOpen];
            [vOpen release];
            [UIView animateWithDuration:0.5f animations:^(void) {
                vOpen.transform = CGAffineTransformIdentity;
            }];
            break;
        case BSTableTypeKaiTai:
            alert = [[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"isCancel Table"] delegate:self cancelButtonTitle:[langSetting localizedString:@"NO"] otherButtonTitles:[langSetting localizedString:@"OrderDishes"],[langSetting localizedString:@"YES"], nil];
            alert.tag = kCancelTag;
            [alert show];
            [alert release];
            break;
        
        case BSTableTypeDianCan:{
            [SVProgressHUD showWithStatus:@"等待..." maskType:SVProgressHUDMaskTypeClear];
            [NSThread detachNewThreadSelector:@selector(_diCan) toTarget:self withObject:nil];
        }
            break;
            
        case BSTableTypeCaiQi:{
            [SVProgressHUD showWithStatus:@"等待..." maskType:SVProgressHUDMaskTypeClear];
            [NSThread detachNewThreadSelector:@selector(_caiQi) toTarget:self withObject:nil];
        }
            break;
        
        default:
            break;
    }
}

//点菜
-(void)_diCan{
    @autoreleasepool {
        NSDictionary *dicResult = (NSDictionary *)[[BSDataProvider sharedInstance] getOrdersBytabNum:[[self.aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"]];
        
        if ([[dicResult objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD dismiss];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"],@"table", nil];
            BSLogViewController *vcLog = [[BSLogViewController alloc] init];
            vcLog.dicInfo = dict;
            [self.viewController.navigationController pushViewController:vcLog animated:YES];
        }else{
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[dicResult objectForKey:@"Message"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
    }
}

//菜齐
-(void)_caiQi{
    @autoreleasepool {
        NSDictionary *dicResult = (NSDictionary *)[[BSDataProvider sharedInstance] getOrdersBytabNum:[[self.aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"]];
        
        if ([[dicResult objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD dismiss];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"],@"table", nil];
            BSLogViewController *vcLog = [[BSLogViewController alloc] init];
            vcLog.dicInfo = dict;
            [self.viewController.navigationController pushViewController:vcLog animated:YES];
        }else{
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[dicResult objectForKey:@"Message"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark AlertViewDelegate
- (int)indexOfButtonCoveredPoint:(CGPoint)pt{
    int i = -1;
    
    
    for (BSTableButton *btn in scvTables.subviews){
        if ([btn isKindOfClass:[BSTableButton class]]){
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
        if (buttonIndex==2) {
            [self cancelTableWithOptions:nil];
        }else if (buttonIndex==1){
            [SVProgressHUD showWithStatus:@"" maskType:SVProgressHUDMaskTypeClear];
            [NSThread detachNewThreadSelector:@selector(_dianCan) toTarget:self withObject:nil];
        }
        
    }else if (111 == alertView.tag){  //跳转到点菜页面
        if (buttonIndex == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:@"openTable" forKey:@"enterState"];
            //桌号已经在开台成功的时候赋值了
            //         [[NSUserDefaults standardUserDefaults] setObject:[[self.aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"] forKey:@"tableNum"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self _order];
        }
    }
}
//点餐
-(void)_dianCan{
    @autoreleasepool {
        [SVProgressHUD showWithStatus:@"" maskType:SVProgressHUDMaskTypeClear];
        NSDictionary *dicResult = (NSDictionary *)[[BSDataProvider sharedInstance] getOrdersBytabNum:[[self.aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"]];
        if ([[dicResult objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD dismiss];
            [[NSUserDefaults standardUserDefaults] setObject:@"order" forKey:@"enterState"];
            [[NSUserDefaults standardUserDefaults] setObject:[[self.aryTables objectAtIndex:dSelectedIndex] objectForKey:@"name"] forKey:@"tableNum"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self _order];
        }else{
            [SVProgressHUD dismiss];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[dicResult objectForKey:@"Message"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}
//跳转点菜页面
- (void)_order{
    BSBookViewController *vcBook = [[BSBookViewController alloc] init];
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
        lbl.lineBreakMode = NSLineBreakByWordWrapping;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = str;
        [lbl sizeToFit];
        for (UILabel *lbl in alert.subviews){
            if ([lbl isKindOfClass:[UILabel class]] && ![lbl.text isEqualToString:@"预订信息"]){
                lbl.textAlignment = NSTextAlignmentCenter;
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
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//    NSString *user = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
//    
//    self.aryResvResult = [[BSDataProvider sharedInstance] pListResv:[NSDictionary dictionaryWithObjectsAndKeys:user,@"user", nil]];
//}

#pragma mark - NSNotification
-(void)ChangeLeftTable:(NSNotification *)notification{
    [self dismissViews];
    int row = [[notification object] integerValue];
    NSDictionary *info = nil;
    switch (row) {
        case 0:
            //正在获取台位
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"Get ramadhin"]];
            [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
            info = nil;
            self.checkTableInfo = info;
            break;
        
        case 1:
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"Get ramadhin"]];
            info = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"status", nil];
            self.checkTableInfo = info;
            [NSThread detachNewThreadSelector:@selector(loadData:) toTarget:self withObject:info];
            break;
         
        case 2:
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"Get ramadhin"]];
            info = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"status", nil];
            self.checkTableInfo = info;
            [NSThread detachNewThreadSelector:@selector(loadData:) toTarget:self withObject:info];
            break;
            
        case 3:
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"Get ramadhin"]];
            info = [NSDictionary dictionaryWithObjectsAndKeys:@"3",@"status", nil];
            self.checkTableInfo = info;
            [NSThread detachNewThreadSelector:@selector(loadData:) toTarget:self withObject:info];
            break;
            
        case 4:
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"Get ramadhin"]];
            info = [NSDictionary dictionaryWithObjectsAndKeys:@"10",@"status", nil];
            self.checkTableInfo = info;
            [NSThread detachNewThreadSelector:@selector(loadData:) toTarget:self withObject:info];
            break;
         
        case 5:
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"Get ramadhin"]];
            info = [NSDictionary dictionaryWithObjectsAndKeys:@"4",@"status", nil];
            self.checkTableInfo = info;
            [NSThread detachNewThreadSelector:@selector(loadData:) toTarget:self withObject:info];
            break;
            
        default:
            break;
    }
}

- (void)loadData:(NSDictionary *)info{
    for (UIView *v in scvTables.subviews){
        if ([v isKindOfClass:[BSTableButton class]])
            [v removeFromSuperview];
    }
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pListTable:info];
        
        if ([[dict objectForKey:@"Result"] boolValue]){
            [SVProgressHUD dismiss];
            NSArray *ary = [dict objectForKey:@"Message"];
            
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=0;i<ary.count;i++){
                NSDictionary *dict = [ary objectAtIndex:i];
                [mut addObject:dict];
            }
            NSArray *aryPX = [NSArray arrayWithArray:mut];
            self.aryTables = [[aryPX sortedArrayUsingFunction:intSort3 context:NULL] retain];
            self.aryTableResult = [self.aryTables retain];
            [self showTables:aryTables];
        }else{
            [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
        }
    }
}

#pragma mark - UISearchBarDelegate
//如果输入框里面的值改变开始重新搜索
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@",searchText);
    [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:searchByName phoneMatch:nil];
    NSNumber *localID = nil;
    NSMutableString *matchString = [NSMutableString string];
    NSMutableArray *matchPos = [NSMutableArray array];
    searchByResult = [NSMutableArray array];
    for (int i=0; i<[searchByName count]; i++) {
        //姓名匹配 获取对应匹配的拼音串 及高亮位置
        localID = [self.searchByName objectAtIndex:i];
        if ([searchBar.text length]) {
            [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
        }
        //按照筛选出得itcode查出菜品放入数组中
        NSString *tableName = [self.contactDic objectForKey:localID];
        for (NSMutableDictionary *dic in self.aryTableResult) {
            if ([[dic objectForKey:@"name"] isEqualToString:tableName]) {
                [searchByResult addObject:dic];
                break;
            }
        }
    }
    NSArray *aryPX = [NSArray arrayWithArray:searchByResult];
    searchByResult = (NSMutableArray *)[aryPX sortedArrayUsingFunction:intSort3 context:NULL];
    self.aryTables = [searchByResult retain];
    [searchByResult retain];
    [self showTables:searchByResult];
}


#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
    float offset = scrollView.contentOffset.y;
    if (offset < -30) {
        [self refreshTable];
    }
}

@end
