//
//  BSSearchViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-25.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "ZCBSBookViewController.h"
#import "BSDataProvider.h"
#import "ZCOrderFoodViewController.h"
#import "ZCBSOrderViewController.h"
#import "ZCLeftMenuTypeViewController.h"
#import "ZCBSBookCell.h"
#import "ZCPackageViewController.h"
#import "ZCPackAdditionsViewController.h"
#import "CVLocalizationSetting.h"
#import "AppDelegate.h"

@interface ZCBSBookViewController ()

@end

@implementation ZCBSBookViewController
@synthesize aryResult,strPriceKey,strUnitKey,aryAddition,arySerach,aryPackage;

static bool boolSearch = NO;
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.aryResult = nil;
    [tvResult release];
    [super dealloc];
}

//刷新台位列表
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSString *enterState = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZCenterState"];
    if ([enterState isEqualToString:@"ZCopenTable"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshZCTableList" object:nil];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isPack = YES;//判断是否数据库中又套餐
    langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    classArray = [[NSMutableArray alloc] init];
    classArray = [[dp getClassList] retain];
    
    //左边类
    tvClass = [[ZCLeftClassTable alloc] init];
    self.aryResult = [NSMutableArray array];
    
    //搜索按钮
    butSerachFood = [UIButton buttonWithType:UIButtonTypeCustom];
    [butSerachFood addTarget:self action:@selector(buttonSerachClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *img = [UIImage imageNamed:@"butSearch"];
    UIEdgeInsets insets1 = UIEdgeInsetsMake(1, 1, 28, 10);
    UIImage *imgRe = [img resizableImageWithCapInsets:insets1];
    butSerachFood.frame = CGRectMake(0, 0, kLeftTableWidth, 30);
    [butSerachFood setBackgroundImage:imgRe forState:UIControlStateNormal];
    [self.view addSubview:butSerachFood];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        tvClass.frame = CGRectMake(0, 30, kLeftTableWidth-2, ScreenHeight-44-20-30);
        tvResult = [[UITableView alloc] initWithFrame:CGRectMake(kLeftTableWidth, 0, ScreenWidth-kLeftTableWidth, ScreenHeight-44-20) style:UITableViewStylePlain];
        imgSeparator = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftTableWidth-2, 0, 2, ScreenHeight-44-20)];
    }else{
        tvClass.frame = CGRectMake(0, 30, kLeftTableWidth-2, ScreenHeight-44-30);
        tvResult = [[UITableView alloc] initWithFrame:CGRectMake(kLeftTableWidth, 0, ScreenWidth-kLeftTableWidth, ScreenHeight-44) style:UITableViewStylePlain];
        imgSeparator = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftTableWidth-2, 0, 2, ScreenHeight-44)];
    }
    
    //添加单击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    tap.delegate = self;
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [tvResult addGestureRecognizer:tap];
    [tap release];
    
    //中间分割线
    [imgSeparator setImage:[UIImage imageNamed:@"separator"]];
    [self.view addSubview:imgSeparator];
    [imgSeparator release];
    
    //菜品table
    tvResult.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvResult.delegate = self;
    tvResult.dataSource = self;
    [self.view addSubview:tvResult];
    [tvResult release];
    [self.view addSubview:tvClass];
    
    [self getTypeFoodList:-1]; //页面初始化的时候加载所有的菜品
    
    imgv = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imgv setImage:[UIImage imageNamed:@"padbg.png"]];
    imgv.userInteractionEnabled = YES;
    imgv.hidden = YES;
    [self.view addSubview:imgv];
    [imgv release];
    
    tfInput = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 260, 32)];
    tfInput.borderStyle = UITextBorderStyleRoundedRect;
    tfInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tfInput.placeholder = [langSetting localizedString:@"Search"]; //搜索
    [imgv addSubview:tfInput];
    [tfInput release];
    
    SWInputView *iw = [[[SWInputView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 243)] autorelease];
    iw.delegate = self;
    tfInput.inputView = iw;
    [tfInput resignFirstResponder];

     btnKeyBoard = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnKeyBoard setImage:[UIImage imageNamed:@"paddown.png"] forState:UIControlStateNormal];
    [btnKeyBoard setImage:[UIImage imageNamed:@"paddownsel.png"] forState:UIControlStateHighlighted];
    [btnKeyBoard sizeToFit];
    btnKeyBoard.frame = CGRectMake(280, 10, 35, 32);
    [btnKeyBoard addTarget:self action:@selector(updownClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgv addSubview:btnKeyBoard];

    //动画
    butMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img1 = [UIImage imageNamed:@"money"];
    CGFloat top = 1; // 顶端盖高度
    CGFloat bottom = 41 ; // 底端盖高度
    CGFloat left = 20; // 左端盖宽度
    CGFloat right = 30; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    UIImage *imgR = [img1 resizableImageWithCapInsets:insets];
    [butMenu setBackgroundImage:imgR forState:UIControlStateNormal];
    //    [butMenu setTitle:@"￥:100元" forState:UIControlStateNormal];
    butMenu.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    butMenu.tag = 55;
    butMenu.hidden = YES;
    
    allPriceLable = [[RTLabel alloc] init];
    allPriceLable.textColor = [UIColor whiteColor];
    allPriceLable.backgroundColor = [UIColor clearColor];
    allPriceLable.font = [UIFont systemFontOfSize:12.0f];
    allPriceLable.hidden = YES;
    allPriceLable.userInteractionEnabled = YES;
    

    
    
    imgMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shopCart"]];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        imgMenu.frame = CGRectMake(ScreenWidth-25, ScreenHeight-32-44-20, 25, 25);
    }else{
        imgMenu.frame = CGRectMake(ScreenWidth-25, ScreenHeight-32-44, 25, 25);
    }
    [self.view addSubview:butMenu];
    [self.view addSubview:allPriceLable];
    [self.view addSubview:imgMenu];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickPrice:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [allPriceLable addGestureRecognizer:singleTap];
    [singleTap release];
    
    [self addCount];//计算总价格
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"ZCChangeTypeNotification" object:nil];
    
    //刷新Table
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"ZCreloadTableNotification" object:nil];
    
    //键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];

}

#pragma mark - actions
//键盘显示 布局改变
-(void)keyboardWillShow
{
    btnKeyBoard.selected = NO;
    [btnKeyBoard setImage:[UIImage imageNamed:@"paddown.png"] forState:UIControlStateNormal];
    [btnKeyBoard setImage:[UIImage imageNamed:@"paddownsel.png"] forState:UIControlStateHighlighted];
    
}

//键盘隐藏  布局改变
-(void)keyboardWillHide
{
    btnKeyBoard.selected = YES;
    [btnKeyBoard setImage:[UIImage imageNamed:@"padup.png"] forState:UIControlStateNormal];
    [btnKeyBoard setImage:[UIImage imageNamed:@"padupsel.png"] forState:UIControlStateHighlighted];
}

- (void)packOK:(ZCPackageViewController *)packView{
    NSMutableDictionary *mutDic = packView.mutAry;
    if (mutDic == NULL) {
        mutDic = packView.packInfo;
    }
    int i = 0;
    for (NSMutableDictionary *dic in aryResult) {
        if ([[dic objectForKey:@"PACKID"] isEqual:[mutDic objectForKey:@"PACKID"]]) {
            [self addFood:mutDic byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
            break;
        }
        i++;
    }
}

//键盘改变的通知 。。。
- (void)orderChanged{
    [tvResult reloadData];
}

- (void)orderClicked{
    ZCOrderFoodViewController *vcOrder = [[ZCOrderFoodViewController alloc] init];
    [self.navigationController pushViewController:vcOrder animated:YES];
    [vcOrder release];
}

- (void)additionClicked{
    
}

- (void)buttonClicked:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.tag==0)
        btnBook.selected = !btnOrdered;
    else
        btnOrdered.selected = !btnBook;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- actions
-(void)buttonSerachClicked:(UIButton *)btn{
    if (boolSearch) {
        imgv.hidden = YES;
        butSerachFood.frame = CGRectMake(0, 0, kLeftTableWidth-2, 30);
        tvClass.frame = CGRectMake(0, 30, kLeftTableWidth-2, ScreenHeight-44-20-30);
        tvResult.frame = CGRectMake(kLeftTableWidth, 0, ScreenWidth-kLeftTableWidth, ScreenHeight-44-20);
        [tfInput resignFirstResponder];
        boolSearch = NO;
    }else{
        imgv.hidden = NO;
        butSerachFood.frame = CGRectMake(0, 50, kLeftTableWidth-2, 30);
        imgv.frame = CGRectMake(0, 0, ScreenWidth, 50);
        tvResult.frame = CGRectMake(kLeftTableWidth, 50, ScreenWidth-kLeftTableWidth, self.view.frame.size.height-44);
        tvClass.frame = CGRectMake(0, 50+30, kLeftTableWidth-2, self.view.frame.size.height-44);
        boolSearch = YES;
    }
}


#pragma mark Notification

-(void)reloadTable{
    [tvResult reloadData];
    [self addCount];
    [self getTypeFoodList:-1]; //页面初始化的时候加载所有的菜品
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCreloadLeftTable" object:nil];
}

#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ZCFoodResultCell";
    ZCBSBookCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[ZCBSBookCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        cell.delegate = self;
    }
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    if ([tfInput.text length] <= 0) {
        if (isPack) {//判断是否有套餐
            if (indexPath.section == 0) {
                cell.dicInfo = [aryPackage objectAtIndex:indexPath.row];
                return cell;
            }else{
                NSMutableArray *aryCount = [NSMutableArray array];
                for (NSMutableDictionary *dic in self.aryResult) {
                    if ([[dic objectForKey:@"CLASS"] integerValue] == indexPath.section) {
                        [aryCount addObject:dic];
                    }
                }
                cell.dicInfo = [aryCount objectAtIndex:indexPath.row];
                return cell;
            }
        }else{
            NSMutableArray *aryCount = [NSMutableArray array];
            for (NSMutableDictionary *dic in self.aryResult) {
                if ([[dic objectForKey:@"CLASS"] integerValue] == indexPath.section+1) {
                    [aryCount addObject:dic];
                }
            }
            cell.dicInfo = [aryCount objectAtIndex:indexPath.row];
            return cell;
        }
        
    }
    cell.dicInfo = [self.arySerach objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *aryCount = [NSMutableArray array];
    if ([tfInput.text length] <= 0) {
        if (isPack) {
            if (section == 0) {
                return [aryPackage count];
            }else{
                for (NSDictionary *dic in aryResult) {
                    if ([[dic objectForKey:@"CLASS"] integerValue] == section) {
                        [aryCount addObject:dic];
                    }
                }
                return [aryCount count];
            }
        }else{
            for (NSDictionary *dic in aryResult) {
                if ([[dic objectForKey:@"CLASS"] integerValue] == section+1) {
                    [aryCount addObject:dic];
                }
            }
            return [aryCount count];
        }
        
    }else{
        return [arySerach count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCreloadLeftTable" object:nil];
    if ([tfInput.text length] <= 0) {
        if (isPack) {
            return [classArray count]+1;
        }else{
            return [classArray count];
        }
        
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *headerTitle;
    if ([tfInput.text length] <= 0) {
        if (isPack) {
            if (section == 0) {
                return @"套餐";
            }else{
                headerTitle = [[classArray objectAtIndex:section-1] objectForKey:@"DES"];
            }
        }else{
            headerTitle = [[classArray objectAtIndex:section] objectForKey:@"DES"];
        }
        
        
    }else{
        int count = [arySerach count];
        headerTitle = [NSString stringWithFormat:[langSetting localizedString:@"Search Conform"],count];
    }
    return headerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [self addFood:[aryResult objectAtIndex:indexPath.row] byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
    
    NSMutableArray *aryCount = [NSMutableArray array];
    if ([tfInput.text length] <= 0) {
        if (isPack) {
            if (indexPath.section == 0) {
                [self addFood:[aryPackage objectAtIndex:indexPath.row] byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
            }else{
                for (NSDictionary *dic in aryResult) {
                    if ([[dic objectForKey:@"CLASS"] integerValue] == indexPath.section) {
                        [aryCount addObject:dic];
                    }
                }
                [self addFood:[aryCount objectAtIndex:indexPath.row] byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
            }
        }else{
            for (NSDictionary *dic in aryResult) {
                if ([[dic objectForKey:@"CLASS"] integerValue] == indexPath.section+1) {
                    [aryCount addObject:dic];
                }
            }
            [self addFood:[aryCount objectAtIndex:indexPath.row] byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
        }
        
    }else{
        [self addFood:[arySerach objectAtIndex:indexPath.row] byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
    }
    [tvResult reloadData];
    
    [self addToShow:indexPath cellx:lx celly:ly+50];
}


- (BOOL)_recursion:(NSString *)item TimeCount:(NSString *)timeCount{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
    for (NSDictionary *food in ary) {
        if ([[food objectForKey:@"OrderTimeCount"] isEqual:timeCount]) {
            for (NSMutableDictionary *dic2 in [food objectForKey:@"foods"]) {
                if ([[dic2 objectForKey:@"ITEM"] isEqual:item] && ![dic2 objectForKey:@"addition"]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(NSString *)_timeCount:(NSString *)packID{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    NSString *str = @"-1";
    for (NSDictionary *food in ary) {
        if ([[food objectForKey:@"PACKID"] isEqual:packID]) {
            for (NSMutableDictionary *dic2 in [food objectForKey:@"foods"]) {
                if ([dic2 objectForKey:@"addition"]) {
                    str = @"-1";
                    break;
                }else{
                    str = [food objectForKey:@"OrderTimeCount"];
                }
            }
        }
    }
    return str;
}

- (void)addFood:(NSDictionary *)foodInfo byCount:(NSString *)count{
    NSString *itcode = [foodInfo objectForKey:@"ITCODE"];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    NSString *packID = [foodInfo objectForKey:@"PACKID"];
    BOOL bpackAge = NO;
    BOOL bpack = NO;
    
    
    if (packID != NULL) {  //套餐的处理
        NSMutableArray *ay = [foodInfo objectForKey:@"foods"];
        NSString *timeCount = [self _timeCount:packID];
        
        for (NSDictionary *f in ay) {
          bpack = [self _recursion:[f objectForKey:@"ITEM"] TimeCount:timeCount];
            if (!bpack) {
                bpack = NO;
                break;
            }
        }
        
        for (NSDictionary *food in ary) {
            if ([[food objectForKey:@"PACKID"] isEqualToString:packID] && bpack
                && [[food objectForKey:@"OrderTimeCount"] isEqual:timeCount]){                bpackAge = YES;
                float total = [[food objectForKey:@"total"] floatValue];
                total += [count floatValue];
                if (total>0){
                    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:food];
                    [mut setObject:[NSString stringWithFormat:@"%.1f",total] forKey:@"total"];
                    [ary replaceObjectAtIndex:[ary indexOfObject:food] withObject:mut];
                }else
                    [ary removeObject:food];
                
                [dp saveOrders];
                break;
            }
        }
        
        
        if (!bpackAge && [count floatValue]>0){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:foodInfo forKey:@"foods"];
            [dict setObject:count forKey:@"total"];
            
            if (self.aryAddition)
                [dict setObject:aryAddition forKey:@"addition"];
            
            if (self.strUnitKey){
                [dict setObject:strUnitKey forKey:@"unitKey"];
                [dict setObject:strPriceKey forKey:@"priceKey"];
            }
            
            [dp orderFood_zc:dict];
            
            self.strUnitKey = @"UNIT";
            self.strPriceKey = @"PRICE";
            
        }
    }else{  //普通菜品的处理
    
    BOOL bFinded = NO;
    
    for (NSDictionary *food in ary){
        if (![food objectForKey:@"addition"]
            && ![[food objectForKey:@"isPack"] boolValue]
            && [[[food objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:itcode]){
            bFinded = YES;
            float total = [[food objectForKey:@"total"] floatValue];
            total += [count floatValue];
            
            if (total>0){
                NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:food];
                [mut setObject:[NSString stringWithFormat:@"%.1f",total] forKey:@"total"];
                [ary replaceObjectAtIndex:[ary indexOfObject:food] withObject:mut];
            }else
                [ary removeObject:food];
            
            [dp saveOrders];
            break;
        }
    }
    
    
    if (!bFinded && [count floatValue]>0){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:foodInfo forKey:@"food"];
        [dict setObject:count forKey:@"total"];
        
        if (self.aryAddition)
            [dict setObject:aryAddition forKey:@"addition"];
        
        if (self.strUnitKey){
            [dict setObject:strUnitKey forKey:@"unitKey"];
            [dict setObject:strPriceKey forKey:@"priceKey"];
        }
        
        [dp orderFood_zc:dict];
    
        self.strUnitKey = @"UNIT";
        self.strPriceKey = @"PRICE";
        
    }
    }

//    [SVProgressHUD showSuccessWithStatus:[langSetting localizedString:@"Order Succeeded"]];
}


#pragma mark - SWKeyboard Delegate
- (void)keyboardTextChanged:(NSString *)inputText{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    self.arySerach = nil;
    int len = inputText.length;
    BOOL isPY = YES;
    NSMutableString *strPY = [NSMutableString string];
    for (int i=0;i<len;i++){
        NSRange range = NSMakeRange(i, 1);
        NSString *str = [inputText substringWithRange:range];
        if ([str isEqualToString:@"1"])
            isPY = NO;
        NSArray *arystr = [@",,ABC,DEF,GHI,JKL,MON,PQRS,TUV,WXYZ" componentsSeparatedByString:@","];
        NSString *strary = [arystr objectAtIndex:[str intValue]];
        if (strary.length>0)
            [strPY appendFormat:@"[%@]",strary];
    }

    NSString *sqlStr = [NSString stringWithFormat:@"(ITCODE like '%@') or (DESCE GLOB '*%@*') or (INIT GLOB '*%@*')",inputText,strPY,strPY];
    self.arySerach = [dp getFoodList:sqlStr];
    [tvResult reloadData];
    
    
    
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
//    self.arySerach = nil;
//    int len = inputText.length;
//    BOOL isPY = YES;
//    NSMutableString *strPY = [NSMutableString string];
//    for (int i=0;i<len;i++){
//        NSRange range = NSMakeRange(i, 1);
//        NSString *str = [inputText substringWithRange:range];
//        if ([str isEqualToString:@"1"])
//            isPY = NO;
//        NSArray *arystr = [@",,ABC,DEF,GHI,JKL,MON,PQRS,TUV,WXYZ" componentsSeparatedByString:@","];
//        NSString *strary = [arystr objectAtIndex:[str intValue]];
//        if (strary.length>0)
//            [strPY appendFormat:@"[%@]",strary];
//    }
//    
//    NSArray *ary = [dp getFoodList:[NSString stringWithFormat:@"(ITCODE like '%%%@%%') or (DESCE GLOB '*%@*') or (INIT GLOB '*%@*')",inputText,strPY,strPY]];
//    [aryResult addObjectsFromArray:ary];
//    [tvResult reloadData];
}
//#pragma mark - UISearchBarDelegate
//搜索框的代理
//- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
//{
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
//    self.aryResult = nil;
//    NSString *sqlStr = [NSString stringWithFormat:@" (ITCODE like '%%%@%%') or (DESCE LIKE '%%%@%%') or (INIT LIKE '%%%@%%')",searchText,searchText,searchText];
//    self.aryResult = [dp getFoodList:sqlStr];
//    [tvResult reloadData];
//}

#pragma mark - Notification
//按照类别查询调用的通知方法
-(void)refreshTable:(NSNotification *)notification{
    NSString *typeID = (NSString *)notification.object;
    int tid = [typeID intValue];
   [self getTypeFoodList:tid];
}
//查询所有菜品
//- (void )getTypeFoodList:(int *)typeID{
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
//    self.aryResult = nil;
//    int a = typeID;
//    NSString *sqlStr;
//    if (a == 0) {
//        sqlStr = @"1=1";
//    }else if(a == 1){
//        //当套餐的子菜品是一个的时候，foods里面存放的是字典，为了统一，也转换成数组
//        NSMutableArray *mutAry = (NSMutableArray *)[dp getPackage];
//        for (NSMutableDictionary *mutDic in mutAry) {
//            NSArray *ary =[mutDic objectForKey:@"foods"];
//            if (![ary isKindOfClass:[NSArray class]]) {
//                NSMutableArray *mut = [[NSMutableArray alloc] init];
//                [mut addObject:ary];
//                [mutDic removeObjectForKey:@"foods"];
//                [mutDic setObject:mut forKey:@"foods"];
//            }
//        }
//        self.aryResult = mutAry;
//        [tvResult reloadData];
//       
//        return;
//    }else{
//        sqlStr = [NSString stringWithFormat:@"class=%d",a-1];
//    }
//    self.aryResult = [[dp getFoodList:sqlStr] retain];
//    [tvResult reloadData];
//}


- (void )getTypeFoodList:(int *)typeID{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //    self.aryResult = nil;
    int a = typeID;
    NSString *sqlStr;
    if (a == -1) {
        sqlStr = @"1=1";
        NSMutableArray *aryFood = [NSMutableArray arrayWithArray:[dp getFoodList:sqlStr]];
//        self.aryResult =
        NSMutableArray *mutAry = (NSMutableArray *)[dp getPackage];
        for (NSMutableDictionary *mutDic in mutAry) {
            NSArray *ary =[mutDic objectForKey:@"foods"];
            if (![ary isKindOfClass:[NSArray class]]) {
                NSMutableArray *mut = [[NSMutableArray alloc] init];
                [mut addObject:ary];
                [mutDic removeObjectForKey:@"foods"];
                [mutDic setObject:mut forKey:@"foods"];
            }
        }
        for (NSDictionary *dicPack in mutAry) {
            [aryFood addObject:dicPack];
        }
        aryPackage = [mutAry retain];
        if ([aryPackage count] >0) {
            isPack = YES;
        }else{
            isPack = NO;
        }
        self.aryResult = [aryFood retain];
        [tvResult reloadData];
    }else if(a == -2){//暂时没用
        //当套餐的子菜品是一个的时候，foods里面存放的是字典，为了统一，也转换成数组
        NSMutableArray *mutAry = (NSMutableArray *)[dp getPackage];
        for (NSMutableDictionary *mutDic in mutAry) {
            NSArray *ary =[mutDic objectForKey:@"foods"];
            if (![ary isKindOfClass:[NSArray class]]) {
                NSMutableArray *mut = [[NSMutableArray alloc] init];
                [mut addObject:ary];
                [mutDic removeObjectForKey:@"foods"];
                [mutDic setObject:mut forKey:@"foods"];
            }
        }
        aryPackage = mutAry;
        [tvResult reloadData];
    }else{
        [tvResult reloadData];
        if ([tfInput.text length] <= 0) {
            NSString *strSql = [NSString stringWithFormat:@"CLASS = %d",a];
            NSMutableArray *aryFood = [NSMutableArray arrayWithArray:[dp getFoodList:strSql]];
            if ([aryFood count] > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:a];
                [tvResult scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
    float offset = scrollView.contentOffset.y;
    if (offset < -30) {
        imgv.hidden = NO;
        boolSearch = YES;
        butSerachFood.frame = CGRectMake(0, 50, kLeftTableWidth-2, 30);
        imgv.frame = CGRectMake(0, 0, ScreenWidth, 50);
        tvResult.frame = CGRectMake(kLeftTableWidth, 50, ScreenWidth-kLeftTableWidth, self.view.frame.size.height-44);
        tvClass.frame = CGRectMake(0, 50+30, kLeftTableWidth-2, self.view.frame.size.height-44-30);
    }
    
}

//搜索框旁边的隐藏键盘按钮
- (void)updownClicked:(UIButton *)btn{
    btn.selected = !btn.selected;
    NSString *str = btn.selected?@"up":@"down";
    if (btn.selected){
        [tfInput resignFirstResponder];
    }else{
        [tfInput becomeFirstResponder];
    }
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pad%@.png",str]] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pad%@sel.png",str]] forState:UIControlStateHighlighted];
}


#pragma mark - SWInputView Delegate
- (void)keyboardPressed:(UIButton *)btn{
    if (btn.tag<10){
        NSMutableString *str = [NSMutableString string];
        [str appendString:tfInput.text];
        [str appendString:[NSString stringWithFormat:@"%d",btn.tag]];
        tfInput.text = str;
    }else if (11==btn.tag){
        if (tfInput.text.length>0)
            tfInput.text = [tfInput.text substringToIndex:tfInput.text.length-1];
    }
    [self keyboardTextChanged:tfInput.text];

}

#pragma mark - BSBookCellDelegate
- (void)detailButAction:(ZCBSBookCell *)cell{
    ZCPackageViewController *pack = [[ZCPackageViewController alloc] init];
    pack.packInfo = cell.dicInfo;
    pack.delegate = self;
    [self.viewController.navigationController pushViewController:pack animated:YES];
    [pack release];    
}

#pragma mark - ations
//已点菜品事件
- (void)showOrdered{
    ZCBSOrderViewController *vcOrder = [[ZCBSOrderViewController alloc] init];
    [vcOrder addNavBack];
    [vcOrder addBGColor:[UIColor whiteColor]];
    [vcOrder setNavTitle:[langSetting localizedString:@"Food"]]; //已点菜品
    [self.navigationController pushViewController:vcOrder animated:YES];
    [vcOrder release];
}

//已点菜品事件   单机总价格
-(void)tapClickPrice:(UITapGestureRecognizer *)tap{
    ZCBSOrderViewController *vcOrder = [[ZCBSOrderViewController alloc] init];
    [vcOrder addNavBack];
    [vcOrder addBGColor:[UIColor whiteColor]];
    [vcOrder setNavTitle:[langSetting localizedString:@"Food"]];
    [self.viewController.navigationController pushViewController:vcOrder animated:YES];
    [vcOrder release];
}

#pragma mark  点菜动画

//重写UIGestureRecognizerDelegate种的方法，解决手势和TableView的didSelect方法不能同时调用的问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    //    NSLog(@"%@", NSStringFromClass([touch.view class]));
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    NSLog(@"%@",NSStringFromClass([touch.view class]));
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"] | [NSStringFromClass([touch.view class]) isEqualToString:@"RTLabel"]) {
        CGPoint p = [touch locationInView:self.view];
        lx = p.x;
        ly = p.y;
        return NO;
    }
    return  YES;
}

//单击事件
-(void)tapClick:(UITapGestureRecognizer *)tap{
    CGPoint p = [tap locationInView:self.view];
    NSLog(@"%f===%f", p.y,p.x);
}

-(void)addToShow:(NSIndexPath *)indexPath cellx:(float)x1 celly:(float)y1{
    
    //声音
    BOOL sound = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sound"] boolValue];
    if (sound) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"addFood" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        SystemSoundID soundId;
        AudioServicesCreateSystemSoundID((CFURLRef)url, &soundId);
        AudioServicesPlaySystemSound(soundId);
    }
    
    //得到产品信息
    NSDictionary *dic = [aryResult objectAtIndex:indexPath.row];
    addPrice = [[dic valueForKey:@"PRICE"] intValue];
    
    //加入购物车动画效果
    CALayer *transitionLayer = [[CALayer alloc] init];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    transitionLayer.opacity = 1.0;
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"foodview"]];
    //    transitionLayer.contents = (id)bt.titleLabel.layer.contents;
    transitionLayer.contents = (id)img.layer.contents;
    //    transitionLayer.frame = [[UIApplication sharedApplication].keyWindow convertRect:bt.titleLabel.bounds fromView:bt.titleLabel];
    transitionLayer.frame = CGRectMake(x1, y1, 20, 20);
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:transitionLayer];
    [CATransaction commit];
    [img release];
    
    //路径曲线
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:transitionLayer.position];
    CGPoint toPoint = CGPointMake(imgMenu.center.x, imgMenu.center.y+120);
    //    CGPoint toPoint = CGPointMake(0, 0);
    [movePath addQuadCurveToPoint:toPoint
                     controlPoint:CGPointMake(imgMenu.center.x,transitionLayer.position.y-120)];
    //    [movePath addQuadCurveToPoint:toPoint
    //                     controlPoint:CGPointMake(shopCarBt.center.x,0)];
    //关键帧
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = movePath.CGPath;
    positionAnimation.removedOnCompletion = YES;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime();
    group.duration = 0.7;
    group.animations = [NSArray arrayWithObjects:positionAnimation,nil];
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.autoreverses= NO;
    
    [transitionLayer addAnimation:group forKey:@"opacity"];
    [self performSelector:@selector(addShopFinished:) withObject:transitionLayer afterDelay:0.5f];
}

//计算总价格
-(float)addCount{
    allPrice = 0;
    NSMutableArray *aryMutOrder = [[BSDataProvider sharedInstance] orderedFood];
    for (NSDictionary *dicOrder in aryMutOrder) {
        float total = [[dicOrder objectForKey:@"total"] floatValue];
        float price = 0;
        if ([[dicOrder objectForKey:@"isPack"] boolValue]) {
            price = [[dicOrder objectForKey:@"PRICE"] floatValue];
        }else{
            price = [[[dicOrder objectForKey:@"food"] objectForKey:@"PRICE"] floatValue];
        }
        float add = price * total;
        allPrice = allPrice + add;
    }
    if (allPrice > 0) {
        butMenu.hidden = NO;
        allPriceLable.hidden = NO;
        NSString *allP = [NSString stringWithFormat:@"￥:%.2f ",allPrice];
        allPriceLable.text = allP;
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            allPriceLable.frame = CGRectMake(ScreenWidth-25-allPriceLable.optimumSize.width-10, ScreenHeight-32-44-20+5, allPriceLable.optimumSize.width+10, 25);
            butMenu.frame = CGRectMake(ScreenWidth-25-allPriceLable.optimumSize.width-10-10, ScreenHeight-32-44-20, allPriceLable.optimumSize.width+10+12+10, 25);
        }else{
            allPriceLable.frame = CGRectMake(ScreenWidth-25-allPriceLable.optimumSize.width-10, ScreenHeight-32-44+5, allPriceLable.optimumSize.width+10, 25);
            butMenu.frame = CGRectMake(ScreenWidth-25-allPriceLable.optimumSize.width-10-10, ScreenHeight-32-44, allPriceLable.optimumSize.width+10+12+10, 25);
        }
        
    }else{
        butMenu.hidden = YES;
        allPriceLable.hidden = YES;
        allPriceLable.text = @"0";
    }
    return allPrice;
}

//加入购物车 步骤2
- (void)addShopFinished:(CALayer*)transitionLayer{
    
    [tvResult reloadData];
    
    allPrice = [self addCount];//计算总价格
    
    transitionLayer.opacity = 0;
    
    //价格上浮的动画效果
    //    UILabel *addLabel = (UILabel*)[self.view viewWithTag:66];
    UILabel *addLabel = [[UILabel alloc] init];
    addLabel.frame = CGRectMake(150, 424, 79, 21);
    addLabel.opaque = NO;
    addLabel.alpha = 0;
    addLabel.clipsToBounds = YES;
    addLabel.textColor = [UIColor redColor];
    [addLabel setText:[NSString stringWithFormat:@"+%i",addPrice]];
    
    CALayer *transitionLayer1 = [[CALayer alloc] init];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    transitionLayer1.opacity = 1.0;
    transitionLayer1.contents = (id)addLabel.layer.contents;
    transitionLayer1.frame = [[UIApplication sharedApplication].keyWindow convertRect:addLabel.bounds fromView:addLabel];
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:transitionLayer1];
    [CATransaction commit];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(addLabel.frame.origin.x+30, addLabel.frame.origin.y+20)];
    positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(addLabel.frame.origin.x+30, addLabel.frame.origin.y)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0 * M_PI];
    rotateAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime();
    group.duration = 0.3;
    group.animations = [NSArray arrayWithObjects:positionAnimation,opacityAnimation,nil];
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.autoreverses= NO;
    [transitionLayer1 addAnimation:group forKey:@"opacity"];
    
}
@end
