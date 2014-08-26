//
//  SearchViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-18.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "SearchViewController.h"
#import "BSDataProvider.h"
#import "SearchCell.h"
#import "BSBookViewController.h"
#import "LeftMenuTypeViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController
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
    NSString *tableNum = [NSString stringWithFormat:[langSetting localizedString:@"tableNum"],[dicInfo objectForKey:@"table"]];
    [self setNavTitle:tableNum];
    
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"get the order"]];
    //    [SVProgressHUD showWithStatus:@"正在获取账单"];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        tvSerach = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44-20) style:UITableViewStylePlain];
    }else{
        tvSerach = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44) style:UITableViewStylePlain];
    }
    tvSerach.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvSerach.delegate = self;
    tvSerach.dataSource = self;
    [self.view addSubview:tvSerach];
    [tvSerach release];
    
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
    
    if (indexPath.section==0) {
        static NSString *identifier = @"SerachCell";
        SearchCell *cell = (SearchCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell){
            cell = [[[SearchCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier] autorelease];
        }
        cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
        cell.dicInfo = [self.aryInfo objectAtIndex:indexPath.row];
        return cell;
    }else if(indexPath.section==1)
    {
        static NSString *identifier = @"cell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        }
        cell.textLabel.text=[dicInfoResult objectForKey:@"Additions"];
        return cell;
    }else{
        static NSString *identifier = @"cell1";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        }
        NSLog(@"%d",indexPath.row);
        cell.textLabel.text=[[[dicInfoResult objectForKey:@"orders"] objectAtIndex:indexPath.row]objectForKey:@"name"];
        cell.detailTextLabel.text=[[[dicInfoResult objectForKey:@"orders"] objectAtIndex:indexPath.row] objectForKey:@"price"];
        return cell;
    }
    
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section==0) {
//        return @"已点菜品"
//    }
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return [self.aryInfo count];
    }else if (section==1)
        return 1;
    else
        return [[dicInfoResult objectForKey:@"orders"] count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
    if ([[[self.aryInfo objectAtIndex:indexPath.row] objectForKey:@"additions"]length]>2)
        return 80;
    else
        return 50;
    }else
    {
        return 30;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        NSDictionary *dic = [self addCount];
        if ([[dic objectForKey:@"totalFood"] isEqualToString:@"0"] && [[dic objectForKey:@"totalTC"] isEqualToString:@"0"]) {
            return Nil;
        }
        
        NSString *str = [NSString stringWithFormat:[langSetting localizedString:@"allPrice"],[dic objectForKey:@"totalFood"],[dic objectForKey:@"totalTC"],[dic objectForKey:@"allPrice"],[dic objectForKey:@"add"]];
        
        return str;
    }else if (section==1){
        return @"全单附加项";
    }else{
        return @"结算方式";
    }
    
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
        add+=[[dic1 objectForKey:@"fujiaprice"]floatValue];
        allPrice = allPrice + price;
    }
    NSString *all = [NSString stringWithFormat:@"%.2f",allPrice];
    return [NSDictionary dictionaryWithObjectsAndKeys:all,@"allPrice",[NSString stringWithFormat:@"%d",totalTC],@"totalTC",[NSString stringWithFormat:@"%d",totalFood],@"totalFood",[NSString stringWithFormat:@"%.2f",add],@"add", nil];
}
@end
