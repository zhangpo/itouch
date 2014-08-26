//
//  PackAdditionsViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-12.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "ZCPackAdditionsViewController.h"
#import "ZCPackAdditionsCell.h"
#import "BSDataProvider.h"
#import "CVLocalizationSetting.h"

@interface ZCPackAdditionsViewController ()

@end

@implementation ZCPackAdditionsViewController

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
    CVLocalizationSetting *langSetting = langSetting = [CVLocalizationSetting sharedInstance];
	[self addNavBack];
    [self setNavTitle:[langSetting localizedString:@"Package Detail"]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        packageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20)];
    }else{
        packageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44)];
    }
    
    packageTable.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    packageTable.delegate = self;
    packageTable.dataSource = self;
    [self.view addSubview:packageTable];
    [packageTable release];
    
    NSArray *ary = [self.packInfo objectForKey:@"foods"];
    if ([ary isKindOfClass:[NSArray class]]) {
        dicInfo = [[NSMutableArray arrayWithArray:ary] retain];
    }else{
        NSMutableArray *mut = [[NSMutableArray alloc] init];
        [mut addObject:ary];
        dicInfo = [[NSMutableArray arrayWithArray:mut] retain];
    }
}


#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PackAdditionsCell";
    ZCPackAdditionsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[ZCPackAdditionsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
        cell.delegate = self;
    }
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.itemInfo = [dicInfo objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dicInfo count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  PackAdditionsCell Delegate
//增加附加项
- (void)cellUpdated:(ZCPackAdditionsCell *)cell{
    packMutDic = self.packInfo;
    NSMutableArray *mutAry = [packMutDic objectForKey:@"foods"];
    int i = 0;
    for (NSMutableDictionary *mutDic in mutAry) {
        if ([[mutDic objectForKey:@"ITEM"] isEqual:[cell.itemInfo objectForKey:@"ITEM"]]) {
            [mutAry replaceObjectAtIndex:i withObject:cell.itemInfo];
            break;
        }
        i++;
    }
    [packMutDic removeObjectForKey:@"foods"];
    [packMutDic setObject:mutAry forKey:@"foods"];
    NSArray *ary = [packMutDic objectForKey:@"foods"];
    if ([ary isKindOfClass:[NSArray class]]) {
        dicInfo = [[NSMutableArray arrayWithArray:ary] retain];
    }else{
        NSMutableArray *mut = [[NSMutableArray alloc] init];
        [mut addObject:ary];
        dicInfo = [[NSMutableArray arrayWithArray:mut] retain];
    }
     [[BSDataProvider sharedInstance] saveOrders];
    [packageTable reloadData];
 
}

@end
