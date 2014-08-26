//
//  SearchViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-18.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "SettleViewController.h"
#import "BSDataProvider.h"
#import "SettleCell.h"
#import "BSBookViewController.h"
#import "AppDelegate.h"
#import "LeftMenuTypeViewController.h"
#import "sharedData.h"
#import "BankCardView.h"
#import "favorableViewController.h"

#define KzhiFuWanCheng 101
@interface SettleViewController ()

@end

@implementation SettleViewController
@synthesize dicInfo,aryInfo;

- (void)dealloc{
    self.dicInfo = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	langSetting = [CVLocalizationSetting sharedInstance];
    [self addBGColor:nil];
    [self addNavBack];
    [self addNavButtonWithTitle:[langSetting localizedString:@"VIP"] atPosition:SWNavItemPositionRight action:@selector(showVIP)];
    [sharedData sharedInstance];
    NSString *tableNum = [NSString stringWithFormat:[langSetting localizedString:@"tableNum"],[dicInfo objectForKey:@"table"]];
    [self setNavTitle:tableNum];
    
    aryFangShi = [[NSMutableArray array] retain];
    UITabBar *tabbar = [[UITabBar alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:tabbar];
    [tabbar release];
    tabbar.delegate = self;
    
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"get the order"]];
    //    [SVProgressHUD showWithStatus:@"正在获取账单"];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        tvSerach = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44-20-44) style:UITableViewStylePlain];
        tabbar.frame = CGRectMake(0, ScreenHeight-44*2-20, ScreenWidth, 44);
    }else{
        tvSerach = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44-44) style:UITableViewStylePlain];
        tabbar.frame = CGRectMake(0, ScreenHeight-44*2, ScreenWidth, 44);
    }
    tvSerach.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvSerach.delegate = self;
    tvSerach.dataSource = self;
    [self.view addSubview:tvSerach];
    [tvSerach release];
    
    //tabbar
    NSString *momey = [langSetting localizedString:@"momey"];
    NSString *bankcard = [langSetting localizedString:@"bank card"];
    NSString *favorable = [langSetting localizedString:@"favorable"];
    NSString *print = [langSetting localizedString:@"print"];
    
    NSArray *titles = [NSArray arrayWithObjects:momey,bankcard,favorable,print, nil];
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
    
    //手势
    _pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(tuodongView:)];
    _pan.delaysTouchesBegan=YES;
}

- (void)loadData{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
        NSDictionary *dict = [dp pQuery:dic];
        if ([[dict objectForKey:@"Result"] boolValue]){
            self.aryInfo = [[dict objectForKey:@"Message"] retain];
            dicInfoResult = [[dict objectForKey:@"Info"] retain];
            [tvSerach reloadData];
        }else{
            NSString *msg;
            //            title = [langSetting localizedString:@"Query the order failed"];
            //            title = @"查询账单失败";
            msg = [dict objectForKey:@"Message"];
            langSetting = [CVLocalizationSetting sharedInstance];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
        [SVProgressHUD dismiss];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"SettleCell";
    
    SettleCell *cell = (SettleCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[SettleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    if (indexPath.section == 0) {
        cell.dicInfo = [self.aryInfo objectAtIndex:indexPath.row];
    }else{
        cell.dicFangShi = [aryFangShi objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    [self addCount]; //合计账单价格
    if(section==0)
    {
        return [self.aryInfo count];
    }
    else if(section==1)
    {
        return [aryFangShi count];
    }
    else if(section==2)
    {
        return nil;
    }
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section==0)
    {
        return 20;
    }
    else  if(section==1)
    {
        return 20;
    }
    else if(section==2)
    {
        return 75;
    }
    else
    {
        return 0;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 310, 75)];
    if(section==0)
    {
        //        view.backgroundColor=[UIColor redColor];
        UILabel *count=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 60, 20)];
        count.textAlignment=NSTextAlignmentCenter;
        count.text=@"名称";
        count.backgroundColor=[UIColor clearColor];
        count.font=[UIFont systemFontOfSize:13];
        [view addSubview:count];
        
        UILabel *name=[[UILabel alloc]initWithFrame:CGRectMake(70,0, 190, 20)];
        name.textAlignment=NSTextAlignmentCenter;
        name.text=@"数量";
        name.backgroundColor=[UIColor clearColor];
        name.font=[UIFont systemFontOfSize:13];
        [view addSubview:name];
        
        UILabel *Price=[[UILabel alloc]initWithFrame:CGRectMake(235,0, 60, 20)];
        Price.textAlignment=NSTextAlignmentCenter;
        Price.text=@"价格";
        Price.backgroundColor=[UIColor clearColor];
        Price.font=[UIFont systemFontOfSize:13];
        [view addSubview:Price];
        view.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    }
    else if(section==1)
    {
        UILabel *YouName=[[UILabel alloc]initWithFrame:CGRectMake(10,0, 155, 24)];
        YouName.textAlignment=NSTextAlignmentLeft;
        YouName.text=@"账单金额:";
        YouName.backgroundColor=[UIColor clearColor];
        YouName.font=[UIFont systemFontOfSize:13];
        [view addSubview:YouName];
        
        
        UILabel *YouMoney=[[UILabel alloc]initWithFrame:CGRectMake(250,0, 70, 24)];
        YouMoney.text = [[sharedData sharedInstance] orderMoney];
        YouMoney.backgroundColor=[UIColor clearColor];
        YouMoney.font=[UIFont systemFontOfSize:13];
        [view addSubview:YouMoney];
        
        view.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    }
    else if(section==2)
    {
        UILabel *hejiName=[[UILabel alloc]initWithFrame:CGRectMake(10,0, 155-20, 24)];
        hejiName.textAlignment=NSTextAlignmentLeft;
        hejiName.text=@"应收金额:";
        hejiName.backgroundColor=[UIColor clearColor];
        hejiName.font=[UIFont systemFontOfSize:13];
        [view addSubview:hejiName];
        
        
        UILabel *hejiMoney=[[UILabel alloc]initWithFrame:CGRectMake(250,0, 70, 24)];
//        hejiMoney.text=[NSString stringWithFormat:@"%.2f",yingfuPrice+molingPrice];
        hejiMoney.text= [[sharedData sharedInstance] yingShouMoney];
        hejiMoney.backgroundColor=[UIColor clearColor];
        hejiMoney.font=[UIFont systemFontOfSize:13];
        [view addSubview:hejiMoney];
        
        
        
        UILabel *PayName=[[UILabel alloc]initWithFrame:CGRectMake(10,24, 155-20, 24)];
        PayName.textAlignment=NSTextAlignmentLeft;
        PayName.text=@"应付金额:";
        PayName.backgroundColor=[UIColor clearColor];
        PayName.font=[UIFont systemFontOfSize:13];
        [view addSubview:PayName];
        
        
        UILabel *PayMoney=[[UILabel alloc]initWithFrame:CGRectMake(250,24, 70, 24)];
        
        if([[[sharedData sharedInstance] yingFuMoney] floatValue]>0)
        {
            NSLog(@"%@",[[sharedData sharedInstance] yingFuMoney]);
            PayMoney.text=[[sharedData sharedInstance] yingFuMoney];
        }
        else
        {
            PayMoney.text=@"0.00";
        }
        
        PayMoney.backgroundColor=[UIColor clearColor];
        PayMoney.font=[UIFont systemFontOfSize:13];
        [view addSubview:PayMoney];
        
        
        UILabel *BackName=[[UILabel alloc]initWithFrame:CGRectMake(10,24+24, 155-20, 24)];
        BackName.textAlignment=NSTextAlignmentLeft;
        BackName.text=@"找  零:";
        BackName.backgroundColor=[UIColor clearColor];
        BackName.font=[UIFont systemFontOfSize:13];
        [view addSubview:BackName];
        
        UILabel *BackMoney=[[UILabel alloc]initWithFrame:CGRectMake(250,24+24, 70, 24)];
        if ([[[sharedData sharedInstance] zhaoLingMoney] floatValue] > 0) {
            BackMoney.text= [[sharedData sharedInstance] zhaoLingMoney];
        }else{
            BackMoney.text = @"0.00";
        }
        
        BackMoney.backgroundColor=[UIColor clearColor];
        BackMoney.font=[UIFont systemFontOfSize:13];
        [view addSubview:BackMoney];
        
    }
    
    return view;
}


#pragma mark - 价格
//统计总钱数，计算抹零
-(NSString *)addCount{
    float allPrice = 0;
    int totalTC = 0;
    int totalFood = 0;
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
        
        allPrice = allPrice + price;
    }
    float yingshou = allPrice - 0;
    NSString *ysMoney = [NSString stringWithFormat:@"%.2f",yingshou];
    [sharedData sharedInstance].yingShouMoney = ysMoney;//应收金额
    
    NSString *yingfu = [NSString stringWithFormat:@"%.2f",[self MoLing:ysMoney]];
    [sharedData sharedInstance].yingFuMoney = yingfu; //应付金额
    
    NSString *all = [NSString stringWithFormat:@"%.2f",allPrice];
    [sharedData sharedInstance].orderMoney = all; //账单金额
//    return [NSDictionary dictionaryWithObjectsAndKeys:all,@"allPrice",[NSString stringWithFormat:@"%d",totalTC],@"totalTC",[NSString stringWithFormat:@"%d",totalFood],@"totalFood", nil];
    return all;
}
//抹零
-(float)MoLing:(NSString *)money{
    float molingPrice = 0;
    float yingfuPrice = 0;
    NSString *decimal = [[NSUserDefaults standardUserDefaults] objectForKey:@"decimal"];
    if([decimal isEqualToString:@"0"])
    {
        //        保留两位小数进行计算
        molingPrice=[[NSString stringWithFormat:@"%.2f",[[NSString stringWithFormat:@"%d", [[NSString stringWithFormat:@"%.2f",[money doubleValue]*100]intValue]%100]doubleValue]/100]doubleValue];
        yingfuPrice=[[NSString stringWithFormat:@"%.2f",[money doubleValue]-molingPrice]doubleValue];
    }
    else if([decimal isEqualToString:@"1"])
    {
        molingPrice=[[NSString stringWithFormat:@"%.2f",[[NSString stringWithFormat:@"%d", [[NSString stringWithFormat:@"%.2f",[money doubleValue]*100]intValue]%10]doubleValue]/100]doubleValue];
        yingfuPrice=[[NSString stringWithFormat:@"%.2f",[money doubleValue]-molingPrice]doubleValue];
    }
    else
    {
        molingPrice=[[NSString stringWithFormat:@"%.2f",[[NSString stringWithFormat:@"%d", [[NSString stringWithFormat:@"%.2f",[money doubleValue]*100]intValue]%100]doubleValue]/100]doubleValue];
        yingfuPrice=[[NSString stringWithFormat:@"%.2f",[money doubleValue]-molingPrice]doubleValue];
    }
    NSString *moling = [NSString stringWithFormat:@"%.2f",molingPrice];
    if (molingPrice > 0.0) {
        BOOL flag = YES;
        for (NSDictionary *dic in aryFangShi) {
            if ([[dic objectForKey:@"OPERATENAME"] isEqualToString:@"抹零"]) {
                flag = NO;
            }
        }
        if (flag) {
            [sharedData sharedInstance].moLingMoney = moling;//抹零
            NSMutableDictionary *dicMoLing = [NSMutableDictionary dictionary];
            [dicMoLing setValue:@"抹零" forKey:@"OPERATENAME"];
            [dicMoLing setValue:moling forKey:@"money"];
            [aryFangShi addObject:dicMoLing];
            [aryFangShi retain];
        }
    }
    
    return yingfuPrice;
}

#pragma mark - actions

-(void)showVIP{
    NSLog(@"会员");
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
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    switch (item.tag) {
        
        case 0:{//   现金
            aryMoney = [[dp getsettlementoperate:@"5"] retain];
            if([aryMoney count]==0)
            {
                if(!_moneyView)
                {
                    [self dismissViews];
                    _moneyView=[[AKsMoneyVIew alloc] init];
                    [_moneyView addGestureRecognizer:_pan];
                    [self.view addSubview:_moneyView];
                    _moneyView.delegate=self;
                }else
                {
                    [_moneyView removeFromSuperview];
                    _moneyView  =nil;
                }
            }
            else
            {
                if(!_viewmoney)
                {
                    [self dismissViews];
                    [self greatMonneyView:aryMoney];
                }
                else
                {
                    [_viewmoney removeFromSuperview];
                    _viewmoney  =nil;
                }
            }
        }
            break;
        case 1:{//   银行卡
            aryBank = [[dp getsettlementoperate:@"31"] retain];
            if([aryBank count]==0)
            {
                if(!bankCardView)
                {
                    [self dismissViews];
                    bankCardView=[[BankCardView alloc] init];
                    [bankCardView addGestureRecognizer:_pan];
                    [self.view addSubview:bankCardView];
                    bankCardView.delegate=self;
                }else
                {
                    [bankCardView removeFromSuperview];
                    bankCardView  =nil;
                }
            }
            else
            {
                if(!_viewBank)
                {
                    [self dismissViews];
                    [self greatBankView:aryBank];
                }
                else
                {
                    [_viewBank removeFromSuperview];
                    _viewBank  = nil;
                }
            }
        }
            break;
            
        case 2:{//   优惠方式
            favorableViewController *f = [[favorableViewController alloc] init];
            f.delegate = self;
            f.dicInfo = dicInfoResult;
            [self.navigationController pushViewController:f animated:YES];
        }
            break;
            
        case 3:{//   打印
            
        }
            break;
            
        default:
            break;
    }
}

- (void)dismissViews{
//    [_showSettlement setCanuse:YES];
    if (_moneyView && _moneyView.superview){
        [_moneyView removeFromSuperview];
        _moneyView = nil;
    }
    if (bankCardView && bankCardView.superview){
        [bankCardView removeFromSuperview];
        bankCardView = nil;
    }
    if (_viewBank && _viewBank.superview){
        [_viewBank removeFromSuperview];
        _viewBank = nil;
    }
    if(_viewmoney && _viewmoney.superview)
    {
        [_viewmoney removeFromSuperview];
        _viewmoney = nil;
    }
//    if(_checkView && _checkView.superview)
//    {
//        [_checkView removeFromSuperview];
//        _checkView = nil;
//    }
}

//界面可拖动
-(void)tuodongView:(UIPanGestureRecognizer *)pan
{
    
    UIView *piece = [pan view];
    if ([pan state] == UIGestureRecognizerStateBegan || [pan state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [pan translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y+ translation.y)];
        
        [pan setTranslation:CGPointZero inView:self.view];
    }
    
}

#pragma mark - 现金
-(void)greatMonneyView:(NSArray *)array
{
    //    [self dismissViews];
    _viewmoney=[[UIView alloc]initWithFrame:CGRectMake(20, 40,280, 200)];
    _viewmoney.backgroundColor=[UIColor colorWithRed:26/255.0 green:76/255.0 blue:109/255.0 alpha:1];
    [_viewmoney addGestureRecognizer:_pan];
    int i = 0;
    for (NSDictionary *dicMoney in array)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateHighlighted];
        button.titleLabel.font=[UIFont systemFontOfSize:14];
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        [button setTitle:[NSString stringWithFormat:@"%@",[dicMoney objectForKey:@"OPERATENAME"]] forState:UIControlStateNormal];
        button.tag=i;
        [button addTarget:self action:@selector(ButtonClickMoney:) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(i%3*80+20,i/3*50+20, 75, 45);
        [_viewmoney addSubview:button];
        i++;
    }
    [self.view addSubview:_viewmoney];
}

-(void)ButtonClickMoney:(UIButton *)button
{
    [self dismissViews];
    if (_moneyView){
        [_moneyView removeFromSuperview];
        _moneyView = nil;
    }
    NSDictionary *dic = [aryMoney objectAtIndex:button.tag];
    _moneyView = [[AKsMoneyVIew alloc] initWithFrame:CGRectMake(0, 0, 275, 200) dicMoney:dic];
//    _moneyView = [[AKsMoneyVIew alloc] initWithFrame:CGRectMake(0, 0, 275, 200)];
    _moneyView.delegate = self;
    _moneyView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-130);
    _moneyView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [self.view addSubview:_moneyView];
    [_moneyView release];
    [UIView animateWithDuration:0.5f animations:^(void) {
        _moneyView.transform = CGAffineTransformIdentity;
    }];
    
}

#pragma mark - 现金代理
//- (void)MoneyViewWithOptions:(NSDictionary *)info{
//    if (info) {
//        BOOL flag = NO;
//        float price = [[info objectForKey:@"money"] floatValue];
//        NSMutableArray *ary = [NSMutableArray arrayWithArray:aryFangShi];
//        if ([aryFangShi count] > 0) {
//            for (NSDictionary *dic in aryFangShi) {
//                if ([[dic objectForKey:@"OPERATE"] isEqualToString:[info objectForKey:@"OPERATE"]]) {
//                    float p = [[dic objectForKey:@"money"] floatValue] + price;
//                    NSString *str = [NSString stringWithFormat:@"%.2f",p];
//                    [dic setValue:str forKey:@"money"];
//                    flag = YES;
//                    break;
//                }
//            }
//        }else{
//            flag = YES;
//            [ary addObject:info];
//        }
//        if (!flag) {
//            [ary addObject:info];
//        }
//        aryFangShi = [ary retain];
//        [tvSerach reloadData];
//        [self addPrice];
//        
//    }
//    [self dismissViews];
//    
//}

- (void)MoneyViewWithOptions:(NSDictionary *)info{
    if (info) {
        [aryFangShi addObject:info];
        [aryFangShi retain];
        [tvSerach reloadData];
        [self addPrice];
    }
    [self dismissViews];
    
}

#pragma mark - 银行卡
-(void)greatBankView:(NSArray *)array
{
    //    [self dismissViews];
    _viewBank=[[UIView alloc]initWithFrame:CGRectMake(20, 40,280, 200)];
    _viewBank.backgroundColor=[UIColor colorWithRed:26/255.0 green:76/255.0 blue:109/255.0 alpha:1];
    [_viewBank addGestureRecognizer:_pan];
    int i = 0;
    for (NSDictionary *dicMoney in array)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateHighlighted];
        button.titleLabel.font=[UIFont systemFontOfSize:14];
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        [button setTitle:[NSString stringWithFormat:@"%@",[dicMoney objectForKey:@"OPERATENAME"]] forState:UIControlStateNormal];
        button.tag=i;
        [button addTarget:self action:@selector(ButtonClickBank:) forControlEvents:UIControlEventTouchUpInside];
        button.frame=CGRectMake(i%3*80+20,i/3*50+20, 75, 45);
        [_viewBank addSubview:button];
        i++;
    }
    [self.view addSubview:_viewBank];
}

-(void)ButtonClickBank:(UIButton *)button
{
    [self dismissViews];
    if (bankCardView){
        [bankCardView removeFromSuperview];
        bankCardView = nil;
    }
    NSDictionary *dic = [aryBank objectAtIndex:button.tag];
    bankCardView = [[BankCardView alloc] initWithFrame:CGRectMake(0, 0, 275, 200) dicMoney:dic];
    bankCardView.delegate = self;
    bankCardView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-130);
    bankCardView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [self.view addSubview:bankCardView];
    [_moneyView release];
    [UIView animateWithDuration:0.5f animations:^(void) {
        bankCardView.transform = CGAffineTransformIdentity;
    }];
    
}

- (void)BankCardWithOptions:(NSDictionary *)info{
    if (info) {
        [aryFangShi addObject:info];
        [aryFangShi retain];
        [tvSerach reloadData];
        [self addPrice];
    }
    [self dismissViews];
}

//计算总得支付价格，判断是否支付完成
-(void)addPrice{
    float money = 0.0;
    for (NSDictionary *dic in aryFangShi) {
        money = money + [[dic objectForKey:@"money"] floatValue];
    }
    
    float yingfu = [[[sharedData sharedInstance] orderMoney] floatValue] - money;
    [sharedData sharedInstance].yingFuMoney = [NSString stringWithFormat:@"%.2f",yingfu];
    float yingshou = [[[sharedData sharedInstance] yingShouMoney] floatValue] - money;
    [sharedData sharedInstance].yingShouMoney = [NSString stringWithFormat:@"%.2f",yingshou];
    float zhaoLing = money - [[[sharedData sharedInstance] orderMoney] floatValue];
    [sharedData sharedInstance].zhaoLingMoney = [NSString stringWithFormat:@"%.2f",zhaoLing];
    if (yingshou <= money) {
        [SVProgressHUD showWithStatus:@"正在结算..."];
        [NSThread detachNewThreadSelector:@selector(payFinish) toTarget:self withObject:nil];
    }
}

//结算完成方法
-(void)payFinish{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dic = [dp userPayment:dicInfoResult fangShi:aryFangShi];
        if ([[dic objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD dismiss];
            NSString *msg = nil;
            if ([[[sharedData sharedInstance] zhaoLingMoney] floatValue] > 0) {
                msg = [NSString stringWithFormat:@"需找零：%@元",[[sharedData sharedInstance] zhaoLingMoney]];
            }else{
                msg = nil;
            }
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结算完成返回主界面" message:msg delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                alert.tag = KzhiFuWanCheng;
                [alert show];
            });
        }else{
            [SVProgressHUD dismiss];
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[dic objectForKey:@"Message"] delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
                [alert show];
            });
        }
    }
    
}

#warning 现金支付，优惠方式不拼接

#pragma mark - favorableViewControllerDelegate
-(void)counp:(NSDictionary *)dic{

    [aryFangShi addObject:dic];
    
    [tvSerach reloadData];
    [self addPrice];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == KzhiFuWanCheng) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SendFoodFinish" object:nil];
    }
}

@end
