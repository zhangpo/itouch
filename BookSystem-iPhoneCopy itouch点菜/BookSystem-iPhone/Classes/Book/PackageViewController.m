//
//  PackageViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "PackageViewController.h"
#import "BSDataProvider.h"
#import "BSPackItemViewController.h"
#import "CVLocalizationSetting.h"

@interface PackageViewController ()

@end

@implementation PackageViewController
{
    
}
@synthesize delegate;
-(void)dealloc
{
    selectArray=Nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    langSetting = langSetting = [CVLocalizationSetting sharedInstance];
	[self addNavBack];
    [self setNavTitle:[langSetting localizedString:@"Package Detail"]];//套餐详细
    [self addNavButtonWithTitle:[langSetting localizedString:@"OK"] atPosition:SWNavItemPositionRight action:@selector(packageOK)];
    
    packageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-60)];
    packageTable.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    packageTable.delegate = self;
    packageTable.dataSource = self;
    [self.view addSubview:packageTable];
    [packageTable release];
    selectArray=[[NSMutableArray alloc] init];
    NSArray *ary = [self.packInfo objectForKey:@"foods"];
    NSMutableArray *oldInfo = [NSMutableArray arrayWithArray:ary];
    NSMutableArray *a = [NSMutableArray array];
    int i=0;
    /**
     *  筛选有多少个组
     */
    for (NSDictionary *dict in oldInfo) {
        if ([[dict objectForKey:@"defualtS"] intValue]==0) {
            i++;
        }
    }
    /**
     *  筛选出每一组里面的菜品
     */
    for (int j=0; j<i; j++) {
        NSMutableArray *array=[NSMutableArray array];
        for (NSDictionary *dict in oldInfo) {
            if ([[dict objectForKey:@"PRODUCTTC_ORDER"] intValue]==j+1) {
                [array addObject:dict];
            }
        }
        [a addObject:array];
    }
    /**
     *  将每一组里的最大最小数量放在菜品中，移除defualtS=0重复的
     */
    NSMutableArray *aryNew = [NSMutableArray array];
    NSMutableArray *ar=[NSMutableArray array];
    for (NSMutableArray *arry in a) {
            NSString *tpmin,*tpmax;
            for (NSDictionary *dict in arry) {
                if ([[dict objectForKey:@"defualtS"] intValue]==0&&[arry count]>1) {
                    tpmin=[dict objectForKey:@"MINCNT"];
                    tpmax=[dict objectForKey:@"MAXCNT"];
                    [arry removeObject:dict];
                    break;
                }else
                {
                    tpmin=[dict objectForKey:@"MINCNT"];
                    tpmax=[dict objectForKey:@"MAXCNT"];
                    break;
                }
            }
            for (NSDictionary *dict in arry) {
                if ([[dict objectForKey:@"MINCNT"] intValue]>0) {
                    for (int i=0; i<[[dict objectForKey:@"MINCNT"] intValue]; i++) {
                        [dict setValue:@"1" forKey:@"total"];
                        [selectArray addObject:dict];
                    }
                }
                [dict setValue:tpmin forKey:@"tpmin"];
                [dict setValue:tpmax forKey:@"tpmax"];
            }
            [aryNew addObject:arry];
    }
    if ([ar count]>0) {
        [aryNew addObject:ar];
    }
    
//    
//        for (NSMutableDictionary *mutD in oldInfo) {
//            if ([[mutD objectForKey:@"defualtS"] isEqualToString:@"1"]) {
//                NSString *tag = [mutD objectForKey:@"PRODUCTTC_ORDER"];
//                [a addObject:tag];
//            }
//        }
//    
//        for (NSMutableDictionary *mutD in oldInfo) {
//            for (NSString *tag in a) {
//                if ([[mutD objectForKey:@"PRODUCTTC_ORDER"] isEqualToString:tag]) {
//                    [mutD setObject:@"Y" forKey:@"TAG"];
//                }
//            }
//            if ([[mutD objectForKey:@"defualtS"] isEqualToString:@"0"]) {
//                [aryNew addObject:mutD];
//            }
//        }
    
//    aryNew = [self tcMonetyDetail:self.packInfo foods:aryNew];
    
    dicInfo = [[NSMutableArray arrayWithArray:aryNew] retain];
    
    //不更换菜品，直接点确定的时候调用这个字典
     self.packInfo2 = [[NSMutableDictionary alloc] initWithDictionary:self.packInfo];
    [self.packInfo2 removeObjectForKey:@"foods"];
    [self.packInfo2 setObject:dicInfo forKey:@"foods"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePackageItemAction:) name:@"ChangePackageItemNotification" object:nil];
    
}

#pragma mark - 变价套餐
//替换子菜品价格
-(NSMutableArray *)tcMonetyDetail:(NSMutableDictionary *)info foods:(NSMutableArray *)aryfood{
    NSString *tc = [info objectForKey:@"TCMONEYMODE"];
    
    //计算子菜品总价格
    detailPrice = [self _tcAddDetailPrice:aryfood];//计算默认的详细菜品的总价格
    //    NSString *tcdetailPrice = [NSString stringWithFormat:@"%.1f",detailPrice];
    float tcPrice = [[info objectForKey:@"PRICE"] floatValue];
    float TCZZPirce;
    NSMutableArray *aryDetailFood = nil;
    if ([tc isEqualToString:@"1"]) {  //方式一
        aryDetailFood = [[NSMutableArray alloc] init];
        TCZZPirce = tcPrice;
        float b1 = 0;
        //将套餐的价格平分给每一个子菜品
        for (NSDictionary *dicFood in aryfood) {
            float a1 = [[dicFood objectForKey:@"PRICE1"] floatValue]*tcPrice/detailPrice;
            b1 = b1 + a1;
            NSString *a = [NSString stringWithFormat:@"%.2f",a1];
            [dicFood setValue:a forKey:@"PRICE1"];
            [aryDetailFood addObject:dicFood];
        }
        if (b1 != tcPrice) { //如果套餐明细的总价格与套餐不相等时
            NSDictionary *d = [aryDetailFood objectAtIndex:0];
            float indexPrice = [[d objectForKey:@"PRICE1"] floatValue]+(tcPrice - b1);
            [d setValue:[NSString stringWithFormat:@"%.2f",indexPrice] forKey:@"PRICE1"];
            [aryDetailFood replaceObjectAtIndex:0 withObject:d];
        }
    }else if ([tc isEqualToString:@"2"]){//方式二
        TCZZPirce = detailPrice;
        aryDetailFood = [[NSMutableArray alloc] initWithArray:aryfood];
    }else if ([tc isEqualToString:@"3"]){//方式三
        if (detailPrice > tcPrice){
            TCZZPirce = detailPrice;
            aryDetailFood = [[NSMutableArray alloc] init];
            TCZZPirce = tcPrice;
            float b1 = 0;
            //将套餐的价格平分给每一个子菜品
            for (NSDictionary *dicFood in aryfood) {
                float a1 = [[dicFood objectForKey:@"PRICE1"] floatValue]*tcPrice/detailPrice;
                b1 = b1 + a1;
                NSString *a = [NSString stringWithFormat:@"%.2f",a1];
                [dicFood setValue:a forKey:@"PRICE1"];
                [aryDetailFood addObject:dicFood];
            }
            if (b1 != tcPrice) { //如果套餐明细的总价格与套餐不相等时
                NSDictionary *d = [aryDetailFood objectAtIndex:0];
                float indexPrice = [[d objectForKey:@"PRICE1"] floatValue]+(tcPrice - b1);
                [d setValue:[NSString stringWithFormat:@"%.2f",indexPrice] forKey:@"PRICE1"];
                [aryDetailFood replaceObjectAtIndex:0 withObject:d];
            }
        }else{
            TCZZPirce = tcPrice;
            aryDetailFood = [[NSMutableArray alloc] initWithArray:aryfood];
        }
    }else{//方式二  以上三种情况都不对的情况下用的方式二
        TCZZPirce = detailPrice;
    }
    return aryDetailFood;
}

//替换子菜品可选菜品的价格
-(NSMutableArray *)tcMonetyDetailItem:(NSMutableDictionary *)info foods:(NSMutableArray *)aryfood{
    NSString *tc = [info objectForKey:@"TCMONEYMODE"];
    float tcPrice = [[info objectForKey:@"PRICE"] floatValue];
//    float tcMoney=[[[_selectArray lastObject] objectForKey:@"PRICE"] floatValue];
    for (NSDictionary *dict in aryfood) {
        if ([[dict objectForKey:@"NADJUSTPRICE"] floatValue]>0) {
            tcPrice+=[[dict objectForKey:@"NADJUSTPRICE"] floatValue]*[[dict objectForKey:@"total"] floatValue];
        }
    }
    [info setObject:[NSNumber numberWithFloat:tcPrice] forKey:@"PRICE"];
    NSMutableArray *aryDetailFood = nil;
    if ([tc isEqualToString:@"1"]) {  //方式一
        aryDetailFood = [[NSMutableArray alloc] init];
        float b1 = 0;
        //将套餐的价格平分给每一个子菜品
        for (NSDictionary *dicFood in aryfood) {
            float a1 = [[dicFood objectForKey:@"PRICE1"] floatValue]*tcPrice/detailPrice;
            b1 = b1 + a1;
            NSString *a = [NSString stringWithFormat:@"%.2f",a1];
            [dicFood setValue:a forKey:@"PRICE1"];
            [aryDetailFood addObject:dicFood];
        }
    }else if ([tc isEqualToString:@"2"]){//方式二
        aryDetailFood = [[NSMutableArray alloc] initWithArray:aryfood];
    }else if ([tc isEqualToString:@"3"]){//方式三
        if (detailPrice > tcPrice){
            aryDetailFood = [[NSMutableArray alloc] init];
            float b1 = 0;
            //将套餐的价格平分给每一个子菜品
            for (NSDictionary *dicFood in aryfood) {
                float a1 = [[dicFood objectForKey:@"PRICE1"] floatValue]*tcPrice/detailPrice;
                b1 = b1 + a1;
                NSString *a = [NSString stringWithFormat:@"%.2f",a1];
                [dicFood setValue:a forKey:@"PRICE1"];
                [aryDetailFood addObject:dicFood];
            }
        }else{
            aryDetailFood = [[NSMutableArray alloc] initWithArray:aryfood];
        }
    }
    return aryDetailFood;
}

//计算默认的详细菜品的总价格
-(float)_tcAddDetailPrice:(NSArray *)aryDetailFood{
    float addDetailPrice = 0;
    for (NSDictionary *dic in aryDetailFood) {
        addDetailPrice = addDetailPrice + [[dic objectForKey:@"PRICE1"] floatValue];
    }
    return addDetailPrice;
}

#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"packageResultCell";    
    BSNewBookCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[BSNewBookCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.selectArray=[NSMutableArray arrayWithArray:selectArray];

    [[[dicInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] setObject:[[[dicInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PNAME"] forKey:@"DES"];
    [[[dicInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] setObject:[[[dicInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PRICE1"] forKey:@"PRICE"];
    cell.dicInfo = [[dicInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[[[dicInfo objectAtIndex:section] lastObject] objectForKey:@"GROUPTITLE"]isEqualToString:@"~_GROUPTITLE_~"]) {
        [[[dicInfo objectAtIndex:section] lastObject] setObject:@"" forKey:@"GROUPTITLE"];
    }
    return [NSString stringWithFormat:@"%d %@ %@-%@",section+1,[[[dicInfo objectAtIndex:section] lastObject] objectForKey:@"GROUPTITLE"],[[[dicInfo objectAtIndex:section] lastObject] objectForKey:@"tpmin"],[[[dicInfo objectAtIndex:section] lastObject] objectForKey:@"tpmax"]];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dicInfo count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[dicInfo objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dic = [[dicInfo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [dic setObject:@"1" forKey:@"total"];
    int i=0,j=0;
    /**
     *  判断是否满足最大最小数量的限制
     */
    for (NSDictionary *dict in selectArray) {
        if ([[dic objectForKey:@"PCODE1"]isEqualToString:[dict objectForKey:@"PCODE1"]]&&[[dic objectForKey:@"PRODUCTTC_ORDER"]isEqualToString:[dict objectForKey:@"PRODUCTTC_ORDER"]]) {
            i++;
            if (i>=[[dic objectForKey:@"MAXCNT"] intValue]) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"已超过该菜品的最大数量" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
                [alert show];
                return;
            }
            
        }
        if ([[dic objectForKey:@"PRODUCTTC_ORDER"]isEqualToString:[dict objectForKey:@"PRODUCTTC_ORDER"]]) {
            j++;
            if (j>=[[dic objectForKey:@"tpmax"] intValue]) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"已超过该组的最大数量" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
                [alert show];
                return;
            }
            
        }
    }
    [selectArray addObject:[NSMutableDictionary dictionaryWithDictionary:dic]];
    NSString *packID = [dic objectForKey:@"PCODE"];
    NSString *item = [dic objectForKey:@"PRODUCTTC_ORDER"];
    NSString *tag = [dic objectForKey:@"TAG"];
    [packageTable reloadData];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSArray *array = [dp getShiftFood:item ofPackage:packID];
    
    if ([tag isEqualToString:@"Y"] && array != NULL) {
        NSMutableArray *mutAry = [NSMutableArray array];
        for (NSDictionary *dic in array) {
            [dic setValue:@"Y" forKey:@"TAG"];
            [mutAry addObject:dic];
        }
        BSPackItemViewController *packItem = [[BSPackItemViewController alloc] init];
        mutAry = [self tcMonetyDetailItem:self.packInfo foods:mutAry];
        packItem.itemAry = (NSMutableArray *)mutAry;
        [self.navigationController pushViewController:packItem animated:YES];
    }
}


#pragma mark - actions
- (void)packageOK{
    int j=0;
    for (NSArray *array  in dicInfo) {
        int i=0;
        for (NSDictionary *dict in array) {
            if ([dict objectForKey:@"total"]) {
                i++;
            }
        }
        if (i<[[[array lastObject] objectForKey:@"tpmin"] intValue]) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%d层没有选择完毕",j+1] message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
            [alert release];
             return;
        }
         j++;
    }
    self.mutAry = [[NSMutableDictionary alloc] initWithDictionary:self.packInfo];
    [self.mutAry removeObjectForKey:@"foods"];
    [self.mutAry setObject:selectArray forKey:@"foods"];
    if ([self.delegate respondsToSelector:@selector(packOK:)]) {
        [self.delegate packOK:self];
    }
    [self.navigationController popViewControllerAnimated:YES];

    //刷新菜单也Table，显示已点数量用
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableNotification" object:nil];
}

#pragma mark - NSNotificationCenter
- (void)changePackageItemAction:(NSNotification *)notification{
    NSMutableDictionary *dic = (NSMutableDictionary *)[notification object];
    int i = 0;
    for (NSMutableDictionary * mut in dicInfo) {
        if ([[mut objectForKey:@"PRODUCTTC_ORDER"] isEqual:[dic objectForKey:@"PRODUCTTC_ORDER"]]) {
            [dicInfo replaceObjectAtIndex:i withObject:dic];
            [packageTable reloadData];
            break;
        }
        i++;
    }
    self.mutAry = [[NSMutableDictionary alloc] initWithDictionary:self.packInfo];
    [self.mutAry removeObjectForKey:@"foods"];
    [self.mutAry setObject:dicInfo forKey:@"foods"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
