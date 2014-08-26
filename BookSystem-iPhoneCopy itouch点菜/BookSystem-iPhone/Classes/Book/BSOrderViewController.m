//
//  BSOrderViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-3.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "BSOrderViewController.h"
#import "BSDataProvider.h"
#import "PackAdditionsViewController.h"
#import "CVLocalizationSetting.h"
#import "BSLogViewController.h"
#import "BSCacheViewController.h"

@interface BSOrderViewController ()

@end

@implementation BSOrderViewController
@synthesize aryCommonAdditions,aryTables;

- (void)dealloc{
    self.aryCommonAdditions = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    langSetting = [CVLocalizationSetting sharedInstance];
    [self addNavBack];
    [self addBGColor:[UIColor whiteColor]];
    [self setNavTitle:[langSetting localizedString:@"Food"]]; //已点菜品
    self.aryCommonAdditions = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"CommonAdditions"]];
    
    tvList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];    
    tvList.delegate = self;
    tvList.dataSource = self;
    [self.view addSubview:tvList];
    [tvList release];
    
    UITabBar *tabbar = [[UITabBar alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:tabbar];
    [tabbar release];
    tabbar.delegate = self;
    
    //公共附加项显示
    lblAdditions = [[UILabel alloc] init];
    lblAdditions.backgroundColor = [UIColor grayColor];
    lblAdditions.font = [UIFont systemFontOfSize:14.0f];
    lblAdditions.numberOfLines = 3;
    [self.view addSubview:lblAdditions];
    [lblAdditions release];
    
    [self showAdditions];//显示公共附加项
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        tvList.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-44*2-20-30);
        tabbar.frame = CGRectMake(0, ScreenHeight-44*2-20, ScreenWidth, 44);
        lblAdditions.frame = CGRectMake(0, ScreenHeight-44*2-30-20, 320, 30);
    }else{
        tvList.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-44*2-30);
        tabbar.frame = CGRectMake(0, ScreenHeight-44*2, ScreenWidth, 44);
        lblAdditions.frame = CGRectMake(0, ScreenHeight-44*2-30, 320, 30);
    }
    
    NSString *Now = [langSetting localizedString:@"Send Now"];
    NSString *Hold = [langSetting localizedString:@"Send Hold"];
    NSString *Common = [langSetting localizedString:@"Common Additions"];
    NSString *FoodCache = [langSetting localizedString:@"FoodCache"];
   
    
    // 即起Send Now   叫起Send Hold  公共附加项Common Additions
   // NSArray *titles = [@"即起发送,叫起发送,公共附加项" componentsSeparatedByString:@","];
    NSArray *titles = [NSArray arrayWithObjects:Now,Hold,Common,FoodCache, nil];
    NSMutableArray *mut = [NSMutableArray array];
    for (int i=0;i<titles.count;i++){
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:nil image:nil tag:i];
        [mut addObject:item];
        [item release];
    }
    tabbar.items = mut;
    
    
    
    if ([tabbar respondsToSelector:@selector(setBackgroundImage:)]){
        [self generateImagesForTabBar:tabbar];
        
        [tabbar setBackgroundImage:[UIImage imageWithContentsOfFile:[@"BSTabBarBG.png" documentPath]]];
        [tabbar setSelectionIndicatorImage:[UIImage imageWithContentsOfFile:[@"BSTabBarSelectionBG.png" documentPath]]];
    }
    
    
    
    for (int i=0;i<titles.count;i++){
        float w = 320/titles.count;
        w = (int)w;
        UILabel *lbl = [UILabel createLabelWithFrame:CGRectMake(w*i, 0, w, 44) font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [tabbar addSubview:lbl];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = [titles objectAtIndex:i];
    }
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrdered) name:@"UpdateOrderedNumber" object:nil];
    
    //在设置中判断是否可以发送
//    BOOL skipSend = [[NSUserDefaults standardUserDefaults] boolForKey:@"SkipSend"];
//    
//    if (skipSend)
//        [NSThread detachNewThreadSelector:@selector(loadTables) toTarget:self withObject:nil];
}

- (void)updateOrdered{
    [tvList reloadData];
}

//查询台位
- (void)loadTables{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pListTable:nil];
        
        
        if ([[dict objectForKey:@"Result"] boolValue]){
            self.aryTables = [dict objectForKey:@"Message"];
            
        }else{
            sw_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Search Table Failed"] message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            });
        }
    }
}

//统计总钱数，套餐数，菜品数
-(NSDictionary *)addCount{
    float allPrice = 0;
    int totalTC = 0;
    int totalFood = 0;
    float add=0.0f;
    NSMutableArray *aryMutOrder = [[BSDataProvider sharedInstance] orderedFood];
    for (NSDictionary *dicOrder in aryMutOrder) {
        float total = [[dicOrder objectForKey:@"total"] floatValue];
        float price = 0;
        if ([[dicOrder objectForKey:@"ISTC"] boolValue]) {
            totalTC = totalTC + [[dicOrder objectForKey:@"total"] intValue];
            price = [[dicOrder objectForKey:@"PRICE"] floatValue];
            for (NSDictionary *dict in [dicOrder objectForKey:@"foods"]) {
                if ([[dict objectForKey:@"addition"] count]>0) {
                    for (NSDictionary *dic in [dict objectForKey:@"addition"]) {
                        add+=[[dic objectForKey:@"FoodFujia_Checked"] floatValue];
                    }
                    
                }
            }
        }else{
            totalFood = totalFood + [[dicOrder objectForKey:@"total"] intValue];
            price = [[[dicOrder objectForKey:@"food"] objectForKey:@"PRICE"] floatValue];
            if ([[[dicOrder objectForKey:@"food"] objectForKey:@"UNITCUR"] isEqualToString:@"2"]) {
                price = [[[dicOrder objectForKey:@"food"] objectForKey:@"UNITCUR2"] floatValue] * [[[dicOrder objectForKey:@"food"] objectForKey:@"PRICE"] floatValue];
            }
            if ([[dicOrder objectForKey:@"addition"] count]>0) {
                for (NSDictionary *dic in [dicOrder objectForKey:@"addition"]) {
                    add+=[[dic objectForKey:@"FoodFujia_Checked"] floatValue];
                }
            }
        }
        float add = price * total;
        allPrice = allPrice + add;
    }
    NSString *all = [NSString stringWithFormat:@"%.2f",allPrice];
    return [NSDictionary dictionaryWithObjectsAndKeys:all,@"allPrice",[NSString stringWithFormat:@"%d",totalTC],@"totalTC",[NSString stringWithFormat:@"%d",totalFood],@"totalFood",[NSString stringWithFormat:@"%.2f",add],@"add", nil];
}



#pragma mark -  BSOrderedCell Delegate
//增加附加项、删除
- (void)cellUpdated:(BSOrderedCell *)cell{
    NSMutableArray *ary = [[BSDataProvider sharedInstance] orderedFood];
    for (int i=0;i<ary.count;i++){
        NSDictionary *dict = [ary objectAtIndex:i];
        if ([[dict objectForKey:@"OrderTimeCount"] intValue]==[[cell.dicInfo objectForKey:@"OrderTimeCount"] intValue]){
            if ([[cell.dicInfo objectForKey:@"total"] floatValue]>0)
                [ary replaceObjectAtIndex:i withObject:cell.dicInfo];
            else
                [ary removeObjectAtIndex:i];
            [[BSDataProvider sharedInstance] saveOrders];
            
            [tvList reloadData];
        }
    }
}

- (void)Additions:(BSOrderedCell *)cell{
    PackAdditionsViewController *add = [[PackAdditionsViewController alloc] init];
    add.packInfo = [cell dicInfo];
    [self.navigationController pushViewController:add animated:YES];
    [add release];
}

- (void)generateImagesForTabBar:(UITabBar *)tabbar{
    if (1 || ![[NSFileManager defaultManager] fileExistsAtPath:[@"BSTabBarBG.png" documentPath]]){
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        
        float w = 320/tabbar.items.count;
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = imgv.bounds;
        [imgv.layer addSublayer:gradientLayer];
        [gradientLayer release];
        
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:.98 green:.33 blue:.35 alpha:1].CGColor,(id)[UIColor colorWithRed:.55 green:0 blue:.04 alpha:1].CGColor,nil];
        gradientLayer.startPoint = CGPointZero;
        gradientLayer.endPoint = CGPointMake(0.0, 1);
        
        for (int i=1;i<tabbar.items.count;i++){
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(i*w, 0, 1, 44)];
            line.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
            [imgv addSubview:line];
            [line release];
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 44),YES,0.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [imgv.layer renderInContext:ctx];
        UIImage *imgC = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        NSData *data = UIImagePNGRepresentation(imgC);
        [data writeToFile:[@"BSTabBarBG@2x.png" documentPath] atomically:NO];
        [data writeToFile:[@"BSTabBarBG.png" documentPath] atomically:NO];
        
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:.98 green:.79 blue:.45 alpha:1].CGColor,(id)[UIColor colorWithRed:.84 green:.3 blue:.13 alpha:1].CGColor,nil];
        gradientLayer.startPoint = CGPointZero;
        gradientLayer.endPoint = CGPointMake(0.0, 1);
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320/tabbar.items.count, 44),YES,0.0);
        ctx = UIGraphicsGetCurrentContext();
        [imgv.layer renderInContext:ctx];
        imgC = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [imgv release];
        
        data = UIImagePNGRepresentation(imgC);
        [data writeToFile:[@"BSTabBarSelectionBG@2x.png" documentPath] atomically:NO];
        [data writeToFile:[@"BSTabBarSelectionBG.png" documentPath] atomically:NO];
    }
}

#pragma mark - UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"OrderedCellIdentifier";
    
    BSOrderedCell *cell = (BSOrderedCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[BSOrderedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.delegate = self;
    }
    cell.dicInfo = [[[BSDataProvider sharedInstance] orderedFood] objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[BSDataProvider sharedInstance] orderedFood] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 122;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *dic = [self addCount];
    if ([[dic objectForKey:@"totalFood"] isEqualToString:@"0"] && [[dic objectForKey:@"totalTC"] isEqualToString:@"0"]) {
        return Nil;
    }
    NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"allPrice"],[dic objectForKey:@"totalFood"],[dic objectForKey:@"totalTC"],[dic objectForKey:@"allPrice"],[dic objectForKey:@"add"]];
//    NSString *str = @"%@ 单品，%@ 套餐，共计：%@元";
    return str;
}


#pragma mark -  UITabBar Delegate

//中餐
- (void)tabBar_zhongcan:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    switch (item.tag) {
        case 0:{//   即起发送
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the ramadhin"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.delegate = self;
            [alert show];
            [alert release];
            alert.tag = 100+item.tag;
        }
            break;
        case 1:{//   叫起发送
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the ramadhin"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.delegate = self;
            [alert show];
            [alert release];
            alert.tag = 100+item.tag;
        }
            
            break;
        case 2://   公共附加项
        {
            BSAdditionsView *v = [BSAdditionsView additionsViewWithDelegate:self additions:aryCommonAdditions];
            
            [v show];
        }
            break;
        default:
            break;
    }
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    switch (item.tag) {
        case 0:{//   即起发送
            [self sendFood_tabBar:@"1"];
        }
            break;
            
        case 1:{//   叫起发送
            [self sendFood_tabBar:@"2"];
        }
            break;
        case 2:{//
            AdditionsView *v = [AdditionsView additionsViewWithDelegate:self additions:aryCommonAdditions];
            [v show];
        }
            break;
       
        case 3:{//
            BSCacheViewController *vcCache = [[BSCacheViewController alloc] init];
            UINavigationController *vcNav = [[UINavigationController alloc] initWithRootViewController:vcCache];
            [vcCache release];
            vcNav.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentModalViewController:vcNav animated:YES];
            [vcNav release];
        }
            break;
            
        default:
            break;
    }
}


//即起发送和叫起发送tabBar调用
-(void)sendFood_tabBar:(NSString *)immediateOrWait{
    NSString *enterState = [[NSUserDefaults standardUserDefaults] objectForKey:@"enterState"];
    
    if ([enterState isEqualToString:@"order"] || [enterState isEqualToString:@"openTable"] || [enterState isEqualToString:@"addFood"]) { //开台未点进入点菜  和 开台进入
        [SVProgressHUD showWithStatus:[langSetting localizedString:@"sending food"] maskType:SVProgressHUDMaskTypeClear];
//        NSString *str = [immediateOrWait copy];
        [NSThread detachNewThreadSelector:@selector(sendFood:) toTarget:self withObject:immediateOrWait];
        
    }else if ([enterState isEqualToString:@"wait"]){
        //等位点餐
        NSDictionary *dicWaitInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"dicWaitInfo"];
        [SVProgressHUD showWithStatus:[langSetting localizedString:@"sending food"] maskType:SVProgressHUDMaskTypeClear];
        [NSThread detachNewThreadSelector:@selector(sendWaitFood:) toTarget:self withObject:dicWaitInfo];
    }else{//查询进入点菜
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the ramadhin"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tfTable = [alert textFieldAtIndex:0];
        tfTable.keyboardType = UIKeyboardTypeDecimalPad;
        alert.delegate = self;
        [alert show];
        [alert release];
        int tag = [immediateOrWait intValue];
        alert.tag = tag;
    }
}


-(void)sendFood:(NSString *)immediateOrWait{
    @autoreleasepool {
        NSString *tableNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"tableNum"];
//        aryCommonAdditions
        BSDataProvider *dp=[BSDataProvider sharedInstance];
        NSDictionary *dicResult = (NSDictionary *)[dp getOrdersBytabNum:tableNum];
        
        if ([[dicResult objectForKey:@"Result"] boolValue]) {
            NSDictionary *dicRes = [NSDictionary dictionary];
             NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dicResult objectForKey:@"orderID"],@"orderID",tableNum,@"tableNum", aryCommonAdditions,@"CommonAdditions",nil];
            if (aryCommonAdditions) {
                
                dicRes = [dp pSpecialRemark:info];
            }
           
            NSDictionary *result = [NSDictionary dictionary];
            [info setValue:immediateOrWait forKey:@"immediateOrWait"]; //即起叫起标志
            if ([[dp orderedFood] count] > 0) {
                result = (NSDictionary *)[dp pSendTab:[dp orderedFood] options:info]; //发送
                [self sendCompleted:result AdditionsInfo:info]; //发送成功后调用
            }else{
                bs_dispatch_sync_on_main_thread(^{
                    [SVProgressHUD dismiss];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Didn't have some food"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                    [alert show];
                });
            }
            
        }else{
            bs_dispatch_sync_on_main_thread(^{
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"prompt"] message:[dicResult objectForKey:@"Message"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
            });
        }
    }
}
//等位点餐发送
-(void)sendWaitFood:(NSDictionary *)dicWaitInfo{
    @autoreleasepool {
        BSDataProvider *dp=[BSDataProvider sharedInstance];
        NSDictionary *result = [NSDictionary dictionary];
        NSMutableArray *commonAry = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"CommonAdditions"];
        NSDictionary *dicRes = [NSDictionary dictionary];
        if (commonAry) {
            dicRes = [dp pSpecialRemark:dicWaitInfo];
        }
        result = (NSDictionary *)[dp pSendTab:[dp orderedFood] options:dicWaitInfo]; //发送
        [self sendCompleted:result AdditionsInfo:dicWaitInfo]; //发送成功后调用
        
    }
}

//传菜成功之后调用
-(void) sendCompleted:(NSDictionary *)result AdditionsInfo:(NSDictionary *)info{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    BOOL bSucceed = YES;
//    BOOL bSuccessdRemark = YES;
    NSString *title = nil;
    bSucceed = [[result objectForKey:@"Result"] boolValue];
    NSMutableArray *aryDelete = [NSMutableArray array];
    if (bSucceed){
        NSMutableArray *ary = [dp orderedFood];
        NSArray *sorted = [self seperatedByType:ary];
        for (int i=0;i<[sorted count];i++){
            NSArray *foods = [[sorted objectAtIndex:i] objectForKey:@"foods"];
            for (int j=0;j<foods.count;j++){
                [aryDelete addObject:[NSNumber numberWithInt:[ary indexOfObject:[foods objectAtIndex:j]]]];
            }
        }
        
//        bSuccessdRemark = [[dicRes objectForKey:@"Result"] boolValue];
//        if (!bSuccessdRemark) {
//            title = @"菜品上传成功，公共附加项失败！";
//        }else{
//            title = [result objectForKey:@"Message"];
//        }
        title = [result objectForKey:@"Message"];
        [ary removeAllObjects];
        [dp saveOrders];
        [tvList reloadData];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CommonAdditions"];
        [SVProgressHUD showSuccessWithStatus:title];
        
        NSString *enterState = [[NSUserDefaults standardUserDefaults] objectForKey:@"enterState"];
        if ([enterState isEqualToString:@"wait"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SendFoodFinish" object:nil];
        }else{
            //跳转到全单页面
            NSString *tableNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"tableNum"];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tableNum,@"table", nil];
            BSLogViewController *vcLog = [[BSLogViewController alloc] init];
            vcLog.dicInfo = dict;
            [self.navigationController pushViewController:vcLog animated:YES];
            [vcLog release];
        }
        
    }else{
        title = [result objectForKey:@"Message"];
        [SVProgressHUD showErrorWithStatus:title];
    }
    
}


#pragma mark - BSAdditionsView Delegate
- (void)Selected:(NSArray *)additions{
    self.aryCommonAdditions = [NSMutableArray arrayWithArray:additions];
    if (aryCommonAdditions.count>0)
        [[NSUserDefaults standardUserDefaults] setObject:aryCommonAdditions forKey:@"CommonAdditions"];
    else
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CommonAdditions"];
   
    [self showAdditions];
    [tvList reloadData];
}

-(void)showAdditions{
    NSMutableString *strFu = nil;
    strFu = [NSMutableString stringWithString:[langSetting localizedString:@"Special note"]];
    for (NSDictionary *dicAddition in aryCommonAdditions) {
        NSString *strAdditions = [dicAddition objectForKey:@"DES"];
        if (strAdditions) {
            [strFu appendString:strAdditions];
            [strFu appendString:@"、"];
        }
        lblAdditions.text = strFu;
    }
    if ([aryCommonAdditions count] < 1) {
        lblAdditions.text = nil;
    }
}

#pragma mark - Send Actions
#pragma mark - Send Food
- (NSArray *)seperatedByType:(NSArray *)foods{
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    for (int i=0;i<foods.count;i++){
        NSDictionary *dict = [foods objectAtIndex:i];
        BOOL ispack = [[dict objectForKey:@"ISTC"] boolValue];
        if (ispack){
            if (![mut objectForKey:@"pack"]){
                [mut setObject:[NSMutableArray array] forKey:@"pack"];
            }
            
            [[mut objectForKey:@"pack"] addObject:dict];
        }else{
            NSString *classid = [[dict objectForKey:@"food"] objectForKey:@"CLASS"];
            
            if (![mut objectForKey:classid]){
                [mut setObject:[NSMutableArray array] forKey:classid];
            }
            
            [[mut objectForKey:classid] addObject:dict];
        }
    }
    
    NSMutableArray *mutary = [NSMutableArray array];
    for (NSString *key in mut.allKeys){
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[mut objectForKey:key],@"foods",key,@"classid", nil];
        [mutary addObject:dic];
    }
    return [NSArray arrayWithArray:mutary];
}

- (void)sendOrderWithOptions:(NSDictionary *)info{
    [self sendOrder:info];
}

- (void)checkFood:(NSDictionary *)info{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        
        NSArray *ary = [self seperatedByType:[dp orderedFood]];
        
        NSDictionary *dict = [dp checkFoodAvailable:ary];
        
        BOOL bResult = [[dict objectForKey:@"Result"] boolValue];
        
        if (bResult){
            sw_dispatch_sync_on_main_thread(^{
                [SVProgressHUD showWithStatus:[langSetting localizedString:@"No out of stock ，Are uploading Food"]];
                [SVProgressHUD showWithStatus:@"菜品没有沽清,正在上传菜品"];
                [self sendOrder:info];
            });
        }else{
            sw_dispatch_sync_on_main_thread(^{
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
            });
        }
        
        
    }
}

- (void)sendOrder:(NSDictionary *)info{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSString *cmd = [dp pSendTab:[dp orderedFood] options:info];
    [self uploadFood:cmd];
}

#pragma mark -  Upload Using FTP
-(void) requestCompleted:(WRRequest *) request{
    langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    BOOL bSucceed = YES;
    
    NSMutableArray *aryDelete = [NSMutableArray array];
    NSString *title;
    if (bSucceed){
        title = [langSetting localizedString:@"Send Succeeded"];//[langSetting localizedString:@"Send Succeeded"];//@"传菜成功";
        NSMutableArray *ary = [dp orderedFood];
        NSArray *sorted = [self seperatedByType:ary];
        for (int i=0;i<[sorted count];i++){
            NSArray *foods = [[sorted objectAtIndex:i] objectForKey:@"foods"];
            for (int j=0;j<foods.count;j++){
                [aryDelete addObject:[NSNumber numberWithInt:[ary indexOfObject:[foods objectAtIndex:j]]]];
                
            }
            
        }
        
        [ary removeAllObjects];
        
        [dp saveOrders];
        [tvList reloadData];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CommonAdditions"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SendFoodFinish" object:nil];
    }
    else
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    sw_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showSuccessWithStatus:title];
    });
    
}

-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"%@", request.error.message);
    
    langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    BOOL bSucceed = NO;
    
    NSMutableArray *aryDelete = [NSMutableArray array];
    NSString *title;
    if (bSucceed){
        title = [langSetting localizedString:@"Send Succeeded"];//@"传菜成功";
        NSMutableArray *ary = [dp orderedFood];
        NSArray *sorted = [self seperatedByType:ary];
        for (int i=0;i<[sorted count];i++){
            NSArray *foods = [[sorted objectAtIndex:i] objectForKey:@"foods"];
            for (int j=0;j<foods.count;j++){
                [aryDelete addObject:[NSNumber numberWithInt:[ary indexOfObject:[foods objectAtIndex:j]]]];
            }
            
        }
        
        if ([aryDelete count]>0){
            for (int i=[aryDelete count]-1;i>=0;i--){
                [ary removeObjectAtIndex:[[aryDelete objectAtIndex:i] intValue]];
            }
        }
        else
            [ary removeAllObjects];
        
        [dp saveOrders];
        [tvList reloadData];
    }
    else
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    
    //    [SVProgressHUD dismissWithError:title afterDelay:2];
    sw_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showErrorWithStatus:title];
    });
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
    
    //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten
    //'request' is the request that intended to create the file
    return YES;
    
}
- (void)uploadFood:(NSString *)str{
    sw_dispatch_sync_on_main_thread(^{
        NSDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerSettings"] objectForKey:@"ftp"];
        WRRequestUpload *uploader = [[WRRequestUpload alloc] init];
        uploader.delegate = self;
        uploader.hostname = [dict objectForKey:@"ip"];
        uploader.username = [dict objectForKey:@"username"];
        uploader.password = [dict objectForKey:@"password"];
        uploader.sentData = [str dataUsingEncoding:NSUTF8StringEncoding];
       
        NSString *filename = [NSString stringWithFormat:@"%@%lf", [NSString performSelector:@selector(UUIDString)],[[NSDate date] timeIntervalSince1970]];
        uploader.path = [NSString stringWithFormat:@"/orders/%@.order",[filename MD5]];
        
//        NSString *filename = [NSString stringWithFormat:@"%@%lf",[UIDevice currentDevice].uniqueIdentifier,[[NSDate date] timeIntervalSince1970]];
//        uploader.path = [NSString stringWithFormat:@"/orders/%@.order",[filename MD5]];
    
        [uploader start];
    });
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:[langSetting localizedString:@"OK"]]){
        /*中餐
        NSString *table = [[alertView textFieldAtIndex:0] text];
        [self sendOrderWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:table,@"table",100==alertView.tag?@"N":@"Y",@"type",nil]];
         */

        [SVProgressHUD showWithStatus:[langSetting localizedString:@"sending food"] maskType:SVProgressHUDMaskTypeClear];
        NSString *tableNum = [[alertView textFieldAtIndex:0] text];
        [[NSUserDefaults standardUserDefaults] setObject:tableNum forKey:@"tableNum"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSString *tag = [NSString stringWithFormat:@"%d",alertView.tag];
        [NSThread detachNewThreadSelector:@selector(sendFood:) toTarget:self withObject:tag];
    }
}

//发送菜品
//-(void)sendFood1:(NSString *)tableNum{
//    @autoreleasepool {
//        BSDataProvider *dp=[BSDataProvider sharedInstance];
//        NSString *orderID = [self getOrderID:tableNum];
//        if (!orderID) {
//            [SVProgressHUD showSuccessWithStatus:[langSetting localizedString:@"isOpenTable"]];
//            return;
//        }
//        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:orderID,@"orderID",tableNum,@"tableNum", nil];
//        NSDictionary *result = nil;
//        result = (NSDictionary *)[dp pSendTab:[dp orderedFood] options:info];
//        [self sendCompleted:result AdditionsInfo:info];
//    }
//}


//查询账单号
-(NSString *)getOrderID1:(NSString *)tableNum{
    NSString *orderID = nil;
    BSDataProvider *dp=[BSDataProvider sharedInstance];
    NSArray *array=[dp getOrdersBytabNum:tableNum];
    if ([array count] > 1) {
        int i = [array count];
        NSArray *ary = [[array objectAtIndex:i-1] componentsSeparatedByString:@";"];
        orderID = [ary objectAtIndex:0];
        if ([[array objectAtIndex:0] isEqualToString:@"-1"]) {
            [SVProgressHUD showSuccessWithStatus:orderID];
            return nil;
        }
    }else if([array count] == 1){
        NSArray *ary = [[array objectAtIndex:0] componentsSeparatedByString:@";"];
        orderID = [ary objectAtIndex:0];
    }
    return orderID;
}

@end
