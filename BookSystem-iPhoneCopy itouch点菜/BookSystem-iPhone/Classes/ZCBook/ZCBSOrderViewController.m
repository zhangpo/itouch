//
//  BSOrderViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-3.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "ZCBSOrderViewController.h"
#import "BSDataProvider.h"
#import "ZCPackAdditionsViewController.h"
#import "CVLocalizationSetting.h"
#import "BSCacheViewController.h"

@interface ZCBSOrderViewController ()

@end

@implementation ZCBSOrderViewController
@synthesize aryCommonAdditions,aryTables,arySelectedFood;

- (void)dealloc{
    self.aryCommonAdditions = nil;
    self.arySelectedFood = nil;
    [super dealloc];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCreloadTableNotification" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    langSetting = [CVLocalizationSetting sharedInstance];
    self.arySelectedFood = [NSMutableArray array];
//    [self addNavBack];
//    [self addBGColor:[UIColor whiteColor]];
//    [self setNavTitle:[langSetting localizedString:@"Food"]]; //已点菜品
	// Do any additional setup after loading the view.
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
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.text = [titles objectAtIndex:i];
    }
    //在设置中判断是否可以发送
//    BOOL skipSend = [[NSUserDefaults standardUserDefaults] boolForKey:@"SkipSend"];
//    
//    if (skipSend)
    
    NSString *enterState = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZCenterState"];
    if ([enterState isEqualToString:@"ZCquery"]) {
        [NSThread detachNewThreadSelector:@selector(loadTables) toTarget:self withObject:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrdered) name:@"UpdateOrderedNumber" object:nil];
    
}

- (void)updateOrdered{
    [tvList reloadData];
}

//查询台位
- (void)loadTables{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pListTable_zc:nil];
        
        BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
        
        if (bSucceed){
            self.aryTables = [dict objectForKey:@"Message"];
        }
        else{
            sw_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Search Table Failed"] message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询台位失败" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        }
    }
}

#pragma mark -  BSOrderedCell Delegate
//增加附加项、删除
- (void)cellUpdated:(ZCBSOrderedCell *)cell{
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

- (void)Additions:(ZCBSOrderedCell *)cell{
    ZCPackAdditionsViewController *add = [[ZCPackAdditionsViewController alloc] init];
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
    
    ZCBSOrderedCell *cell = (ZCBSOrderedCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[ZCBSOrderedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.delegate = self;
    }
    
    cell.dicInfo = [[[BSDataProvider sharedInstance] orderedFood] objectAtIndex:indexPath.row];
    
//    cell.indexPath = indexPath;
    BOOL bInArray = NO;
    for (NSDictionary *food in arySelectedFood){
        if ([[food objectForKey:@"OrderTimeCount"] intValue]==[[cell.dicInfo objectForKey:@"OrderTimeCount"] intValue]){
            bInArray = YES;
            break;
        }
    }
    
    cell.bSelect = bInArray;
    
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
    NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"allPrice"],[dic objectForKey:@"totalFood"],[dic objectForKey:@"totalTC"],[dic objectForKey:@"allPrice"]];
    //    NSString *str = @"%@ 单品，%@ 套餐，共计：%@元";
    return str;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCBSOrderedCell *cell = (ZCBSOrderedCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    BOOL bInArray = NO;
    NSDictionary *foodIn = nil;
    for (NSDictionary *food in arySelectedFood){
        if ([[food objectForKey:@"OrderTimeCount"] intValue]==[[cell.dicInfo objectForKey:@"OrderTimeCount"] intValue]){
            bInArray = YES;
            foodIn = food;
            break;
        }
    }
    
    if (bInArray){
        [arySelectedFood removeObject:foodIn];
        cell.bSelect = NO;
    }else {
        [arySelectedFood addObject:cell.dicInfo];
        cell.bSelect = YES;
    }
}

//统计总钱数，套餐数，菜品数
-(NSDictionary *)addCount{
    float allPrice = 0;
    int totalTC = 0;
    int totalFood = 0;
    NSMutableArray *aryMutOrder = [[BSDataProvider sharedInstance] orderedFood];
    for (NSDictionary *dicOrder in aryMutOrder) {
        float total = [[dicOrder objectForKey:@"total"] floatValue];
        float price = 0;
        if ([[dicOrder objectForKey:@"isPack"] boolValue]) {
            totalTC = totalTC + [[dicOrder objectForKey:@"total"] intValue];
            price = [[dicOrder objectForKey:@"PRICE"] floatValue];
        }else{
            totalFood = totalFood + [[dicOrder objectForKey:@"total"] intValue];
            price = [[[dicOrder objectForKey:@"food"] objectForKey:@"PRICE"] floatValue];
            if ([[[dicOrder objectForKey:@"food"] objectForKey:@"UNITCUR"] isEqualToString:@"2"]) {
                price = [[[dicOrder objectForKey:@"food"] objectForKey:@"UNITCUR2"] floatValue] * [[[dicOrder objectForKey:@"food"] objectForKey:@"PRICE"] floatValue];
            }
        }
        float add = price * total;
        allPrice = allPrice + add;
    }
    NSString *all = [NSString stringWithFormat:@"%.2f",allPrice];
    return [NSDictionary dictionaryWithObjectsAndKeys:all,@"allPrice",[NSString stringWithFormat:@"%d",totalTC],@"totalTC",[NSString stringWithFormat:@"%d",totalFood],@"totalFood", nil];
}

#pragma mark -  UITabBar Delegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    switch (item.tag) {
        case 0:{//   即起发送
            BSDataProvider *dp = [BSDataProvider sharedInstance];
            if ([[dp orderedFood] count] > 0) { //判断是否有菜品可以发送
                [self sendFood_tabBar:@"N"];
            }else{
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Didn't have some food"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
            }
        }
            break;
        case 1:{//   叫起发送
            BSDataProvider *dp = [BSDataProvider sharedInstance];
            if ([[dp orderedFood] count] > 0) {
                [self sendFood_tabBar:@"Y"];
            }else{
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Didn't have some food"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
            }
        }
            break;
        case 2://   公共附加项
        {
            ZCAdditionsView *v = [ZCAdditionsView additionsViewWithDelegate:self additions:aryCommonAdditions];
            
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
    NSString *enterState = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZCenterState"];
    
    if ([enterState isEqualToString:@"ZCorder"] || [enterState isEqualToString:@"ZCopenTable"] || [enterState isEqualToString:@"ZCaddFood"]) { //开台未点进入点菜  和 开台进入
        [SVProgressHUD showWithStatus:[langSetting localizedString:@"sending food"] maskType:SVProgressHUDMaskTypeClear];
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        NSString *table = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tableNum"] lowercaseString];
        [dicInfo setValue:table forKey:@"table"];
        [dicInfo setValue:immediateOrWait forKey:@"type"]; //即起叫起
        
        [SVProgressHUD showProgress:-1 status:@"正在查询是否沽清"];
        [NSThread detachNewThreadSelector:@selector(checkFood:) toTarget:self withObject:dicInfo];
        
    }else{//查询进入点菜
        if ([immediateOrWait isEqualToString:@"N"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the ramadhin"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.delegate = self;
            [alert show];
            [alert release];
            alert.tag = 100;
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the ramadhin"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.delegate = self;
            [alert show];
            [alert release];
            alert.tag = 101;
        }
    }
}


#pragma mark - ZCAdditionsView Delegate
- (void)additionsSelected:(NSArray *)additions{
    self.aryCommonAdditions = [NSMutableArray arrayWithArray:additions];
    if (aryCommonAdditions.count>0)
        [[NSUserDefaults standardUserDefaults] setObject:aryCommonAdditions forKey:@"CommonAdditions"];
    else
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CommonAdditions"];
    [self showAdditions];
    [tvList reloadData];
}

-(void)showAdditions{
    NSMutableString *strFu = [NSMutableString stringWithString:[langSetting localizedString:@"Special note"]];
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
        BOOL ispack = [[dict objectForKey:@"isPack"] boolValue];
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
    BOOL skipSend = [[NSUserDefaults standardUserDefaults] boolForKey:@"SkipSend"];
    
    if (!skipSend){
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"Without the permission"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    BOOL isValidTable = NO;
    
    for (NSDictionary *table in aryTables){
        if ([[[info objectForKey:@"table"] lowercaseString] isEqualToString:[[table objectForKey:@"short"] lowercaseString]]){
            isValidTable = YES;
            break;
        }
    }
    
    if (!isValidTable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"Table error"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    

    [SVProgressHUD showProgress:-1 status:@"正在查询是否沽清"];
    [NSThread detachNewThreadSelector:@selector(checkFood:) toTarget:self withObject:info];

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
//                [SVProgressHUD showWithStatus:@"菜品没有沽清,正在上传菜品"];
//                [self sendOrder:info];
                [self _jijiaoqi:info];
            });
        }else{
            sw_dispatch_sync_on_main_thread(^{
                [SVProgressHUD dismiss];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
                [alert release];
            });
        }
        
        
    }
}

- (void)sendOrder:(NSDictionary *)info{
    
    NSArray *jiqi = [info objectForKey:@"N"];
    NSArray *jiaoqi = [info objectForKey:@"Y"];
    NSString *strjiqi = nil;
    NSString *strjiaoqi = nil;
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:[info objectForKey:@"options"]];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    if (jiqi){
        [options setObject:@"N" forKey:@"type"];
        strjiqi = [dp pSendTab_zc:jiqi options:options];
    }
    
    if (jiaoqi){
        [options setObject:@"Y" forKey:@"type"];
        strjiaoqi = [dp pSendTab_zc:jiaoqi options:options];
    }
    
    NSString *cmd = nil;
    if (strjiaoqi && strjiqi){
        cmd = [NSString stringWithFormat:@"%@#%@",strjiqi,strjiaoqi];
    }else if (strjiaoqi && !strjiqi)
        cmd = strjiaoqi;
    else
        cmd = strjiqi;
    
    [self uploadFood:cmd];
    
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
//    NSString *cmd = [dp pSendTab_zc:[dp orderedFood] options:info];
//    [self uploadFood:cmd];
}

-(void)_jijiaoqi:(NSDictionary *)info{
    NSMutableArray *jiqi = [NSMutableArray array];
    NSMutableArray *jiaoqi = [NSMutableArray array];
    NSArray *foods = [[BSDataProvider sharedInstance] orderedFood];
    for (int j=0;j<foods.count;j++){
        NSDictionary *dicfood = [foods objectAtIndex:j];
        BOOL isselected = NO;
        for (NSDictionary *dictselected in arySelectedFood){
            if ([[dicfood objectForKey:@"OrderTimeCount"] intValue]==[[dictselected objectForKey:@"OrderTimeCount"] intValue]){
                isselected = YES;
                break;
            }
        }
        if (isselected)
            [jiaoqi addObject:[foods objectAtIndex:j]];
        else
            [jiqi addObject:[foods objectAtIndex:j]];
    }
    
    NSMutableDictionary *mutfood = [NSMutableDictionary dictionary];
    if ([jiaoqi count]>0)
        [mutfood setObject:jiaoqi forKey:@"Y"];
    if ([jiqi count]>0)
        [mutfood setObject:jiqi forKey:@"N"];
    
    [mutfood setObject:info forKey:@"options"];
    
    [self sendOrder:mutfood];
}


#pragma mark -  Upload Using FTP
-(void) requestCompleted:(WRRequest *) request{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    BOOL bSucceed = YES;
    
    NSMutableArray *aryDelete = [NSMutableArray array];
    NSString *title;
    if (bSucceed){
        NSMutableArray *ary = [dp orderedFood];
        NSArray *sorted = [self seperatedByType:ary];
        for (int i=0;i<[sorted count];i++){
            NSArray *foods = [[sorted objectAtIndex:i] objectForKey:@"foods"];
            for (int j=0;j<foods.count;j++){
                [aryDelete addObject:[NSNumber numberWithInt:[ary indexOfObject:[foods objectAtIndex:j]]]];
            }
        }
        [ary removeAllObjects];
        [arySelectedFood removeAllObjects];
        [dp saveOrders];
        [tvList reloadData];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CommonAdditions"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SendFoodFinish" object:nil];
    }else{
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
        [SVProgressHUD showSuccessWithStatus:title];
    }
}

-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"%@", request.error.message);
    
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
    else{
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
        [SVProgressHUD showErrorWithStatus:title];
    }
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
    
        [uploader start];
    });
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:[langSetting localizedString:@"OK"]]){
        NSString *table = [[alertView textFieldAtIndex:0] text];
        [[NSUserDefaults standardUserDefaults] setObject:table forKey:@"tableNum"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self sendOrderWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:table,@"table",100==alertView.tag?@"N":@"Y",@"type",nil]];
    }
}


@end
