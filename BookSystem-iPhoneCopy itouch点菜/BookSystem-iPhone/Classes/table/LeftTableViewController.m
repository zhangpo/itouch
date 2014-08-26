//
//  LeftTableViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-18.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "LeftTableViewController.h"
#import "AppDelegate.h"

@interface LeftTableViewController ()

@end

@implementation LeftTableViewController

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
    langSetting = [CVLocalizationSetting sharedInstance];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        tabTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height-44-20)];
    }else{
        tabTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height-44)];
    }
	
    tabTable.backgroundColor = [UIColor clearColor];
    tabTable.delegate = self;
    tabTable.dataSource = self;
    tabTable.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    [self.view addSubview:tabTable];
    [tabTable release];
}


#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"tabResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    NSString *strName = nil;
    switch (indexPath.row) {
        case 0:
            strName = [langSetting localizedString:@"All"];
//            strName = @"全部";
            break;
            
        case 1:
//            strName = @"空闲";
            strName = [langSetting localizedString:@"empty"];
            break;
            
        case 2:
//            strName = @"开台未点";
            strName = [langSetting localizedString:@"Open table none food"];
            break;
            
        case 3:
//            strName = @"开台已点";
            strName = [langSetting localizedString:@"Open table food"];
            break;
            
        case 4:
//            strName = @"菜齐";
            strName = [langSetting localizedString:@"Food full"];
            break;
            
        case 5:
//            strName = @"结账";
            strName = [langSetting localizedString:@"The invoicing"];
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = strName;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //显示主视图控制器
//    UIViewController *menuCtrl = [(AppDelegate *)([[UIApplication sharedApplication] delegate]) tableCtrl];
//    [menuCtrl showRootController:YES];

    NSString *stateID = [NSString stringWithFormat:@"%d",indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeLeftTableNotification" object:stateID];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [super dealloc];
}

@end
