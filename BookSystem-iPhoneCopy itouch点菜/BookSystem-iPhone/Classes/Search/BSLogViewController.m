//
//  BSLogViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "BSLogViewController.h"
#import "BSDataProvider.h"
#import "BSQueryCell.h"
#import "BSBookViewController.h"
#import "AppDelegate.h"
#import "LeftMenuTypeViewController.h"
#import "SettleViewController.h"
#import "RightOrderViewController.h"

@interface BSLogViewController ()

@end

@implementation BSLogViewController
@synthesize dicInfo,dicOrder,aryInfo,arySelectedFood;

- (void)dealloc{
    self.dicInfo = nil;
    self.dicOrder = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    arySelectedFood = [[NSMutableArray array] retain];
	langSetting = [CVLocalizationSetting sharedInstance];
    [self addBGColor:nil];
    [self addNavBack];
    //    [self addNavButtonWithTitle:[langSetting localizedString:@"settleaccount"] atPosition:SWNavItemPositionRight action:@selector(showSettle)];
    NSString *tableNum = [NSString stringWithFormat:[langSetting localizedString:@"tableNum"],[dicInfo objectForKey:@"table"]];
    [self setNavTitle:tableNum];
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"get the order"]];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    
    UITabBar *tabbar = [[UITabBar alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:tabbar];
    [tabbar release];
    tabbar.delegate = self;
    
    lblAdditions = [[UILabel alloc] init];
    lblAdditions.backgroundColor = [UIColor grayColor];
    lblAdditions.font = [UIFont systemFontOfSize:14.0f];
    lblAdditions.numberOfLines = 3;
    [self.view addSubview:lblAdditions];
    [lblAdditions release];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        tvFood = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44-44-20-30) style:UITableViewStylePlain];
        tabbar.frame = CGRectMake(0, ScreenHeight-44*2-20, ScreenWidth, 44);
        lblAdditions.frame = CGRectMake(0, ScreenHeight-44*2-30-20, 320, 30);
    }else{
        tvFood = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44-44-30) style:UITableViewStylePlain];
        tabbar.frame = CGRectMake(0, ScreenHeight-44*2, ScreenWidth, 44);
        lblAdditions.frame = CGRectMake(0, ScreenHeight-44*2-30, 320, 30);
    }
    tvFood.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvFood.delegate = self;
    tvFood.dataSource = self;
    [self.view addSubview:tvFood];
    [tvFood release];
    
    //tabbar
    NSString *all=@"全选";
    NSString *push = [langSetting localizedString:@"Push Food"];
    NSString *elide = [langSetting localizedString:@"Elide Food"];
    NSString *add = [langSetting localizedString:@"addFood"];
    NSString *reElide = [langSetting localizedString:@"reCallElide"];
    
    NSArray *titles = [NSArray arrayWithObjects:all,push,elide,reElide,add, nil];
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
}

- (void)loadData{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
        
        //        NSDictionary *dict = [dp pQuery:dic];
        NSDictionary *dict = [dp queryWholeProducts:dic];
        //        NSDictionary *dict = [dp queryCompletely:dic];
        if ([[dict objectForKey:@"Result"] boolValue]){
            self.aryInfo = [[dict objectForKey:@"Message"] retain];
            dicInfoResult = [[dict objectForKey:@"Info"] retain];
            NSString *strAdditions = [dicInfoResult objectForKey:@"Additions"];
            NSMutableString *strFu = [NSMutableString stringWithString:[langSetting localizedString:@"Special note"]];
            if (strAdditions) {
                [strFu appendString:strAdditions];
            }
            lblAdditions.text = strFu;
            [tvFood reloadData];
            [arySelectedFood release];
            arySelectedFood = nil;
            arySelectedFood = [[NSMutableArray array] retain];
        }else{
            NSString *title,*msg;
            title = [langSetting localizedString:@"Query the order failed"];
            //            title = @"查询账单失败";
            msg = [dict objectForKey:@"Message"];
            langSetting = [CVLocalizationSetting sharedInstance];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
        [SVProgressHUD dismiss];
        
    }
}

//划菜调用刷新，内含调用菜齐接口
- (void)loadData2{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
        
        //        NSDictionary *dict = [dp pQuery:dic];
        NSDictionary *dict = [dp queryWholeProducts:dic];
        //        NSDictionary *dict = [dp queryCompletely:dic];
        if ([[dict objectForKey:@"Result"] boolValue]){
            self.aryInfo = [[dict objectForKey:@"Message"] retain];
            dicInfoResult = [[dict objectForKey:@"Info"] retain];
            
            NSString *strAdditions = [dicInfoResult objectForKey:@"Additions"];
            NSMutableString *strFu = [NSMutableString stringWithString:[langSetting localizedString:@"Special note"]];
            [strFu appendString:strAdditions];
            lblAdditions.text = strFu;
            
            [arySelectedFood release];
            arySelectedFood = nil;
            arySelectedFood = [[NSMutableArray array] retain];
            [tvFood reloadData];
            //            BOOL flag = YES;
            //            //判断是否菜齐
            //            for (NSDictionary *dic in self.aryInfo) {
            //                int pcountPull = [[dic objectForKey:@"pcount"] intValue] - [[dic objectForKey:@"pullCount"] intValue];
            //                if (pcountPull > 0) {
            //                    flag = NO;
            //                    break;
            //                }
            //            }
            //            if (flag) {
            //                [SVProgressHUD showWithStatus:@"正在菜齊..." maskType:SVProgressHUDMaskTypeClear];
            //                [NSThread detachNewThreadSelector:@selector(suppProductsFinish) toTarget:self withObject:nil]; //调用菜齐接口
            //            }
        }else{
            NSString *title,*msg;
            title = [langSetting localizedString:@"Query the order failed"];
            //            title = @"查询账单失败";
            msg = [dict objectForKey:@"Message"];
            langSetting = [CVLocalizationSetting sharedInstance];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
        [SVProgressHUD dismiss];
        
    }
}

-(void)suppProductsFinish{
    @autoreleasepool {
        NSDictionary *dicResult = [[BSDataProvider sharedInstance] suppProductsFinish:dicInfoResult];
        if ([[dicResult objectForKey:@"Result"] boolValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"Food full"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FoodCell";
    
    BSQueryCell *cell = (BSQueryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[BSQueryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.dicInfo = [self.aryInfo objectAtIndex:indexPath.row];
    
    BOOL bInArray = NO;
    for (NSDictionary *dic in arySelectedFood) {
        if ([[dic objectForKey:@"PKID"] isEqualToString:[cell.dicInfo objectForKey:@"PKID"]] && [[dic objectForKey:@"pcode"] isEqualToString:[cell.dicInfo objectForKey:@"pcode"]]){
            bInArray = YES;
            break;
        }
    }
    cell.bSelected = bInArray;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.aryInfo count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *str = [[self.aryInfo objectAtIndex:indexPath.row] objectForKey:@"additions"];
    if ([str count]>0) {
        return 70;
    }else
        return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BSQueryCell *cell = (BSQueryCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL bInArray = NO;
    NSDictionary *foodIn = nil;
    if (![[cell.dicInfo objectForKey:@"IsQuit"] boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"退菜原因" message:[cell.dicInfo objectForKey:@"QuitCause"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    for (NSDictionary *dic in arySelectedFood) {
        if ([[dic objectForKey:@"PKID"] isEqualToString:[cell.dicInfo objectForKey:@"PKID"]] && [[dic objectForKey:@"pcode"] isEqualToString:[cell.dicInfo objectForKey:@"pcode"]]) {
            bInArray = YES;
            foodIn = dic;
            break;
        }
    }
    if (bInArray) {
        cell.bSelected = NO;
        [arySelectedFood removeObject:foodIn];
    }else{
        cell.bSelected = YES;
        [arySelectedFood addObject:cell.dicInfo];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *dic = [self addCount];
    if ([[dic objectForKey:@"totalFood"] isEqualToString:@"0"] && [[dic objectForKey:@"totalTC"] isEqualToString:@"0"]) {
        return Nil;
    }
    
    NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"allPrice"],[dic objectForKey:@"totalFood"],[dic objectForKey:@"totalTC"],[dic objectForKey:@"allPrice"],[dic objectForKey:@"add"]];
    
    //    return [str stringByAppendingFormat:@"  %@",[dicInfoResult objectForKey:@"orderId"]];
    return str;
}

//统计总钱数，套餐数，菜品数
-(NSDictionary *)addCount{
    float allPrice = 0;
    int totalTC = 0;
    int totalFood = 0;
    float add=0.0f;
    NSArray *ary = [NSArray arrayWithArray:self.aryInfo];
    for (NSDictionary *dic1 in ary) {
        float total = 0;
        float price = 0;
        if ([[dic1 objectForKey:@"ISTC"] boolValue] && [[dic1 objectForKey:@"pcode"] isEqualToString:[dic1 objectForKey:@"tpcode"]]) {
            totalTC = totalTC + [[dic1 objectForKey:@"pcount"] intValue];
            price = [[dic1 objectForKey:@"price"] floatValue];
            total = [[dic1 objectForKey:@"pcount"] floatValue];
        }else if(![[dic1 objectForKey:@"ISTC"] boolValue]){
            totalFood = totalFood + [[dic1 objectForKey:@"pcount"] intValue];
            total = [[dic1 objectForKey:@"pcount"] floatValue];
            price = [[dic1 objectForKey:@"price"] floatValue];
            
        
        }
        if ([[dic1 objectForKey:@"additions"] count]>0) {
            for (NSDictionary *dict in [dic1 objectForKey:@"additions"]) {
                add+=[[dict objectForKey:@"fujiaprice"] floatValue];
            }
        }
        allPrice = allPrice + price;
    }
    NSString *all = [NSString stringWithFormat:@"%.2f",allPrice];
    return [NSDictionary dictionaryWithObjectsAndKeys:all,@"allPrice",[NSString stringWithFormat:@"%d",totalTC],@"totalTC",[NSString stringWithFormat:@"%d",totalFood],@"totalFood",[NSString stringWithFormat:@"%.2f",add],@"add", nil];
}

#pragma mark - actions
//加菜方法
-(void)addFood{
    [[NSUserDefaults standardUserDefaults] setObject:@"addFood" forKey:@"enterState"];
    [[NSUserDefaults standardUserDefaults] setObject:[dicInfo objectForKey:@"table"] forKey:@"tableNum"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self _order];
}

- (void)_order{
    
    bs_dispatch_sync_on_main_thread(^{
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
    });
    
}

//预结算
-(void)showSettle{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[dicInfoResult objectForKey:@"tableNum"],@"table", nil];
    SettleViewController *vcLog = [[SettleViewController alloc] init];
    vcLog.dicInfo = dict;
    [self.navigationController pushViewController:vcLog animated:YES];
    [vcLog release];
}

#pragma mark -- tabbar
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

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    switch (item.tag) {
        case 0:{//   推菜
            if ([arySelectedFood count]>0) {
                [arySelectedFood removeAllObjects];
            }else
            {
                [arySelectedFood addObjectsFromArray:self.aryInfo];
            }
            [tvFood reloadData];
            
        }
            break;
        case 1:{//   推菜
            int count = [arySelectedFood count];
            if (count <= 0) {
                [SVProgressHUD showErrorWithStatus:@"没有选择菜品"];
            }else{
                [self removePackage];
                [SVProgressHUD showWithStatus:[langSetting localizedString:@"push"]];
                [NSThread detachNewThreadSelector:@selector(callPubitem) toTarget:self withObject:nil];
            }
            
        }
            break;
        case 2:{//   划菜
            int count = [arySelectedFood count];
            if (count <= 0) {
                
                [SVProgressHUD showErrorWithStatus:@"没有选择菜品"];
            }else{
                x = 0;
                [self removePackage];
                [self arySelectedFoodAndCall];
            }
        }
            break;
            
        case 3:{//   反划
            int count = [arySelectedFood count];
            if (count <= 0) {
                [SVProgressHUD showErrorWithStatus:@"没有选择菜品"];
            }else{
                x = 0;
                [self removePackage];
                [self reArySelectedFoodAndCall];
            }
        }
            break;
            
        case 4:{//   加菜
            [self addFood];
        }
            break;
            
        default:
            break;
    }
}
//催菜
-(void)callPubitem{
    @autoreleasepool {
        BSDataProvider *db = [BSDataProvider sharedInstance];
        for (NSDictionary *dict in arySelectedFood) {
            if ([[dict objectForKey:@"pcount"] intValue] - [[dict objectForKey:@"pullCount"] intValue]==0) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@已上菜不能催",[dict objectForKey:@"pcname"]] message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
                [alert show];
                [SVProgressHUD dismiss];
                return;
            }
        }
        NSDictionary *dic = [db callPubitem:dicInfoResult productList:arySelectedFood];
        
        if ([[dic objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"SuccessRefresh"] maskType:SVProgressHUDMaskTypeClear];
            [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"Message"]];
        }
    }
}

//反划菜
-(void)reCallElide{
    @autoreleasepool {
        NSMutableArray *ary = [NSMutableArray array];
        for (NSDictionary *dic in arySelectedFood) {
            int pcountPull = [[dic objectForKey:@"pullCount"] intValue];
            if (pcountPull > 0) {
                [ary addObject:dic];
            }
        }
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSDictionary *dic = [db reCallElide:dicInfoResult productList:ary];
        if ([[dic objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"SuccessRefresh"] maskType:SVProgressHUDMaskTypeClear];
            [NSThread detachNewThreadSelector:@selector(loadData2) toTarget:self withObject:nil];
            [SVProgressHUD showSuccessWithStatus:[dic objectForKey:@"Message"]];
        }else{
            [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"Message"]];
        }
    }
}
-(void)reArySelectedFoodAndCall{
    if (x == [arySelectedFood count]) {
        [SVProgressHUD showWithStatus:@""];
        [NSThread detachNewThreadSelector:@selector(reCallElide) toTarget:self withObject:nil];
    }else{
        NSMutableDictionary *dic = [arySelectedFood objectAtIndex:x];
        int pcountPull = [[dic objectForKey:@"pullCount"] intValue];
        if ([[dic objectForKey:@"pullCount"] intValue] > 1 ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Cross food quantity"] message:[dic objectForKey:@"pcname"] delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            tfElide = [alert textFieldAtIndex:0];
            tfElide.keyboardType = UIKeyboardTypeNumberPad;
            NSMutableDictionary *dic = [arySelectedFood objectAtIndex:x];
            int pcount = [[dic objectForKey:@"pullCount"] intValue];
            //            NSString *str = [NSString stringWithFormat:@"最多可划%d份",pcount];
            NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"Most strokes vegetables"],pcount];
            
            tfElide.placeholder = str;
            tfElide.delegate = self;
            [alert show];
            alert.tag = 201;
            [alert release];
        }else if (pcountPull <=0 ){
            NSString *caiqi = [NSString stringWithFormat:@"%@反劃完畢",[dic objectForKey:@"pcname"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:caiqi delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles: nil];
            [alert show];
            [alert release];
            [arySelectedFood removeAllObjects];
            [NSThread detachNewThreadSelector:@selector(loadData2) toTarget:self withObject:nil];
            return;
            
            //            x++;
            //            [self reArySelectedFoodAndCall];
        }else{
            [dic setValue:@"1" forKey:@"elideCount"];
            [arySelectedFood replaceObjectAtIndex:x withObject:dic];
            if (x <[arySelectedFood count]) {
                x++;
                [self reArySelectedFoodAndCall];
            }
        }
    }
}

//划菜
-(void)callElide{
    @autoreleasepool {
        NSMutableArray *ary = [NSMutableArray array];
        for (NSDictionary *dic in arySelectedFood) {
            int pcountPull = [[dic objectForKey:@"pcount"] intValue] - [[dic objectForKey:@"pullCount"] intValue];
            if (pcountPull > 0) {
                [ary addObject:dic];
            }
        }
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSDictionary *dic = [db callElide:dicInfoResult productList:ary];
        if ([[dic objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"SuccessRefresh"] maskType:SVProgressHUDMaskTypeClear];
            [NSThread detachNewThreadSelector:@selector(loadData2) toTarget:self withObject:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"Message"]];
        }
    }
}
-(void)arySelectedFoodAndCall{
    if (x == [arySelectedFood count]) {
        [SVProgressHUD showWithStatus:@""];
        [NSThread detachNewThreadSelector:@selector(callElide) toTarget:self withObject:nil];
    }else{
        NSMutableDictionary *dic = [arySelectedFood objectAtIndex:x];
        int pcountPull = [[dic objectForKey:@"pcount"] intValue] - [[dic objectForKey:@"pullCount"] intValue];
        if ([[dic objectForKey:@"pcount"] intValue] > 1 && pcountPull >0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Cross food quantity"] message:[dic objectForKey:@"pcname"] delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            tfElide = [alert textFieldAtIndex:0];
            tfElide.keyboardType = UIKeyboardTypeNumberPad;
            NSMutableDictionary *dic = [arySelectedFood objectAtIndex:x];
            int pcount = [[dic objectForKey:@"pcount"] intValue] - [[dic objectForKey:@"pullCount"] intValue];
            //            NSString *str = [NSString stringWithFormat:@"最多可划%d份",pcount];
            NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"Most strokes vegetables"],pcount];
            
            tfElide.placeholder = str;
            tfElide.delegate = self;
            [alert show];
            alert.tag = 101;
            [alert release];
        }else if (pcountPull <=0 ){
            NSString *caiqi = [NSString stringWithFormat:@"%@已上齊",[dic objectForKey:@"pcname"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:caiqi delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles: nil];
            [alert show];
            [alert release];
            [arySelectedFood removeAllObjects];
            [NSThread detachNewThreadSelector:@selector(loadData2) toTarget:self withObject:nil];
            //            [self arySelectedFoodAndCall];
            return;
        }else{
            [dic setValue:@"1" forKey:@"elideCount"];
            [arySelectedFood replaceObjectAtIndex:x withObject:dic];
            if (x <[arySelectedFood count]) {
                x++;
                [self arySelectedFoodAndCall];
            }
        }
    }
}

#pragma mark - UIAlertDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101) {
        NSString *elideCount = [[alertView textFieldAtIndex:0] text];
        NSMutableDictionary *dic = [arySelectedFood objectAtIndex:x];
        int pcount = [[dic objectForKey:@"pcount"] intValue] - [[dic objectForKey:@"pullCount"] intValue];
        int toBeInt = [elideCount intValue];
        if (buttonIndex == 1) {
            if (elideCount.length > 0 && toBeInt <= pcount) {
                NSMutableDictionary *dic = [arySelectedFood objectAtIndex:x];
                [dic setValue:elideCount forKey:@"elideCount"];
                [arySelectedFood replaceObjectAtIndex:x withObject:dic];
                if (x <[arySelectedFood count]) {
                    x++;
                    [self arySelectedFoodAndCall];
                }
            }else if (toBeInt > pcount) {
                NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"Most strokes vegetables"],pcount];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                alert.tag = 102;
                [alert show];
                [alert release];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"劃菜數量不能爲空" delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
                alert.tag = 103;
                [alert release];
            }
        }
    }else if (alertView.tag == 102 | alertView.tag == 103){
        [self arySelectedFoodAndCall];
    }else if (alertView.tag == 201) {
        NSString *elideCount = [[alertView textFieldAtIndex:0] text];
        NSMutableDictionary *dic = [arySelectedFood objectAtIndex:x];
        int pcount = [[dic objectForKey:@"pullCount"] intValue];
        int toBeInt = [elideCount intValue];
        if (buttonIndex == 1) {
            if (elideCount.length > 0 && toBeInt <= pcount) {
                NSMutableDictionary *dic = [arySelectedFood objectAtIndex:x];
                [dic setValue:elideCount forKey:@"elideCount"];
                [arySelectedFood replaceObjectAtIndex:x withObject:dic];
                if (x <[arySelectedFood count]) {
                    x++;
                    [self reArySelectedFoodAndCall];
                }
            }else if (toBeInt > pcount) {
                NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"Most strokes vegetables"],pcount];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:str delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                alert.tag = 202;
                [alert show];
                [alert release];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"反劃菜數量不能爲空" delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
                alert.tag = 203;
                [alert release];
            }
        }
    }else if (alertView.tag == 202 | alertView.tag == 203){
        [self reArySelectedFoodAndCall];
    }
}
-(void)removePackage
{
    NSMutableArray *array=[NSMutableArray array];
    for (NSDictionary *dict in arySelectedFood) {
        int i=0;
        if ([[dict objectForKey:@"ISTC"] intValue]==1&&[[dict objectForKey:@"pcode"] isEqualToString:[dict objectForKey:@"tpcode"]]) {
            for (NSDictionary *dict1 in arySelectedFood) {
                if ([[dict1 objectForKey:@"ISTC"] intValue]==1&&[[dict objectForKey:@"tpcode"] isEqualToString:[dict objectForKey:@"tpcode"]]&&![[dict1 objectForKey:@"pcode"] isEqualToString:[dict1 objectForKey:@"tpcode"]]&&[[dict1 objectForKey:@"PKID"] isEqualToString:[dict objectForKey:@"PKID"]]){
                    int k=0;
                    if ([array count]==0) {
                        [array addObject:[NSString stringWithFormat:@"%d",i]];
                    }
                    else{
                        for (int j=0;j<[array count];j++) {
                            int y=[[array objectAtIndex:j] intValue];
                            if (y==i) {
                                k++;
                            }
                        }
                        if (k==0) {
                            [array addObject:[NSString stringWithFormat:@"%d",i]];
                        }
                    }
                }
                i++;
            }
        }
    }
    int k=[array count];
    for (int j=0; j<k; j++) {
        [arySelectedFood removeObjectAtIndex:[[array objectAtIndex:j] intValue]-j]
        ;
    }
    
}

@end
