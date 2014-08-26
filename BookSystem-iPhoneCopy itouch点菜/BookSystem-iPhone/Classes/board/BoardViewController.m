//
//  BoardViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-27.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "BoardViewController.h"
#import "CVLocalizationSetting.h"
#import "BoarkCell.h"
#import "BSDataProvider.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    langSetting = [CVLocalizationSetting sharedInstance];
    [self addNavBack];
    [self setNavTitle:[langSetting localizedString:@"boark"]];
    [self addNavButtonWithTitle:[langSetting localizedString:@"refresh"] atPosition:SWNavItemPositionRight action:@selector(Refresh)];
    
    [self Refresh];
    tvBoark = [[UITableView alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        tvBoark.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20);
    }else{
        tvBoark.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-44);
    }
    tvBoark.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvBoark.delegate = self;
    tvBoark.dataSource = self;
    [self.view addSubview:tvBoark];
}

-(void)Refresh{
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeClear];
    [NSThread detachNewThreadSelector:@selector(RefreshBoark) toTarget:self withObject:nil];
}
-(void)RefreshBoark{
    @autoreleasepool {
        NSDictionary *dicInfo = [NSDictionary dictionary];
        dicResult = [[BSDataProvider sharedInstance] pYgSpclList:dicInfo];
        aryResult = [dicResult objectForKey:@"lookMessage"];
        [SVProgressHUD dismiss];
        [tvBoark reloadData];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"BoarkCell";
    
    BoarkCell *cell = (BoarkCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[BoarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.dicInfo = [aryResult objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 36;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 310, 75)];
    if(section==0)
    {
        //        view.backgroundColor=[UIColor redColor];
        UILabel *count=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 100, 20)];
        count.textAlignment=NSTextAlignmentCenter;
        count.text=@"名称";
        count.backgroundColor=[UIColor clearColor];
        count.font=[UIFont systemFontOfSize:13];
        [view addSubview:count];
        
        UILabel *shiji=[[UILabel alloc]initWithFrame:CGRectMake(110,0, 60, 20)];
        shiji.textAlignment=NSTextAlignmentCenter;
        shiji.text=@"实际";
        shiji.backgroundColor=[UIColor clearColor];
        shiji.font=[UIFont systemFontOfSize:13];
        [view addSubview:shiji];
        
        UILabel *yugu=[[UILabel alloc]initWithFrame:CGRectMake(180,0, 60, 20)];
        yugu.textAlignment=NSTextAlignmentCenter;
        yugu.text=@"预估";
        yugu.backgroundColor=[UIColor clearColor];
        yugu.font=[UIFont systemFontOfSize:13];
        [view addSubview:yugu];
        view.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        
        UILabel *wancheng=[[UILabel alloc]initWithFrame:CGRectMake(250,0, 60, 20)];
        wancheng.textAlignment=NSTextAlignmentCenter;
        wancheng.text=@"完成率";
        wancheng.backgroundColor=[UIColor clearColor];
        wancheng.font=[UIFont systemFontOfSize:13];
        [view addSubview:wancheng];
        view.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    }
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
