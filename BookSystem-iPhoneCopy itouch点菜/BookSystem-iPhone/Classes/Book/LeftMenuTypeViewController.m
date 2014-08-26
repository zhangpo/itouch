//
//  LeftMenuTypeViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-2.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "LeftMenuTypeViewController.h"
#import "BSDataProvider.h"
#import "BSBookViewController.h"
#import "AppDelegate.h"

@interface LeftMenuTypeViewController ()

@end

@implementation LeftMenuTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         //self.hidesBottomBarWhenPushed = YES;
        BSDataProvider *dataPro = [BSDataProvider sharedInstance];
        classArray = [[NSMutableArray alloc] init];
       classArray = [[dataPro getClassList] retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        menuType = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height-44-20)];
    }else{
        menuType = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height-44)];
    }
	
    menuType.backgroundColor = [UIColor clearColor];
    menuType.delegate = self;
    menuType.dataSource = self;
    menuType.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    [self.view addSubview:menuType];
    [menuType release];
}


#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"typeResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"全部";
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"套餐";
    }
    else{
        NSDictionary *dic =  [classArray objectAtIndex:indexPath.row-2];
        cell.textLabel.text = [dic objectForKey:@"DES"];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [classArray count]+2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *typeID = 0;
    if (indexPath.row == 0) {
         typeID = @"-1"; //全部
    }else if (indexPath.row == 1){
         typeID = @"-2"; //套餐
    }else{
        NSDictionary *dic =  [classArray objectAtIndex:indexPath.row-2];
        typeID = [dic objectForKey:@"GRP"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeTypeNotification" object:typeID];
    //显示主视图控制器
//    DDMenuController *menuCtrl = [(AppDelegate *)([[UIApplication sharedApplication] delegate]) menuCtrl];
//    [menuCtrl showRootController:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [super dealloc];
    classArray = nil;
    [classArray release];
}

@end
