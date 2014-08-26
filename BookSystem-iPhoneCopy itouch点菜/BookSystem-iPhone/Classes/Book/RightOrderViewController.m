//
//  RightOrderTableViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-24.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "RightOrderViewController.h"
#import "BSDataProvider.h"
#import "RightOrderCell.h"

@interface RightOrderViewController ()

@end

@implementation RightOrderViewController

-(void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [aryOrder release];
    aryOrder = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self getOrder];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRigthtTable) name:@"reloadRigthtTableNotification" object:nil];
    }
    return self;
}

//刷新table
-(void)reloadRigthtTable{
    [self getOrder];
    [tvOrder reloadData];
}

//获取已点菜品内容
-(NSArray *)getorderFood{
    BSDataProvider *dp = [[BSDataProvider alloc] init];
    NSArray *aryOldOrder = [dp orderedFood];
    return aryOldOrder;
}

//循环计算套餐和单品的份数
-(void)getOrder{
    NSArray *aryOldOrder = [self getorderFood];
    [aryOrder release];
    aryOrder = nil;
    NSMutableArray *aryMut = [NSMutableArray array];
    for (NSDictionary *dicOrder in aryOldOrder) {
        BOOL flag = YES;
        for (NSDictionary *dicResult in aryMut) {
            if ([[[dicResult objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:[[dicOrder objectForKey:@"food"] objectForKey:@"ITCODE"]] && ![[dicOrder objectForKey:@"ISTC"] boolValue] && ![[dicResult objectForKey:@"ISTC"] boolValue]) {
                flag = NO;
                break;
            }else if([[dicResult  objectForKey:@"ITCODE"] isEqualToString:[dicOrder  objectForKey:@"ITCODE"]] && [[dicOrder objectForKey:@"ISTC"] boolValue] && [[dicResult objectForKey:@"ISTC"] boolValue]){
                flag = NO;
                break;
            }
        }
        if (flag) {
            [aryMut addObject:dicOrder];
        }
    }
    aryOrder = [[NSArray arrayWithArray:aryMut] retain];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        tvOrder = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 140, self.view.frame.size.height-44-20)];
    }else{
        tvOrder = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 140, self.view.frame.size.height-44)];
    }
	
    tvOrder.backgroundColor = [UIColor clearColor];
    tvOrder.delegate = self;
    tvOrder.dataSource = self;
    tvOrder.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    [self.view addSubview:tvOrder];
    [tvOrder release];
}


#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"OrderCell";
    RightOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[RightOrderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.dicInfo = [aryOrder objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [aryOrder count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
