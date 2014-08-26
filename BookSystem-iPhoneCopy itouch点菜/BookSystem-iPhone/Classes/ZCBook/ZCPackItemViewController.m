//
//  BSPackItemViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-11.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "ZCPackItemViewController.h"
#import "CVLocalizationSetting.h"

@interface ZCPackItemViewController ()

@end

@implementation ZCPackItemViewController

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
    CVLocalizationSetting *langSetting = langSetting = [CVLocalizationSetting sharedInstance];
    [self addNavBack];
    [self setNavTitle:[langSetting localizedString:@"Replaceable"]];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0) {
        packageItemTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20)];
    }else{
        packageItemTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44)];
    }
	
    packageItemTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44)];
    packageItemTable.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    packageItemTable.delegate = self;
    packageItemTable.dataSource = self;
    [self.view addSubview:packageItemTable];
    [packageItemTable release];
    
    if ([self.itemAry isKindOfClass:[NSArray class]]) {
        ary = [[NSMutableArray arrayWithArray:self.itemAry] retain];
    }else{
        NSMutableArray *mut = [[NSMutableArray alloc] init];
        [mut addObject:self.itemAry];
        ary = [[NSMutableArray arrayWithArray:mut] retain];
    }
}


#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"packageItemResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    itemDic = [ary objectAtIndex:indexPath.row];
    cell.textLabel.text = [itemDic objectForKey:@"DES"];
    NSString *price = [NSString stringWithFormat:@"%@/%@   ",[itemDic objectForKey:@"PRICE"],[itemDic objectForKey:@"UNIT"]];
    cell.detailTextLabel.text = price;
    
    cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [ary count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    itemDic = [ary objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCChangePackageItemNotification" object:itemDic];
}
#pragma mark - actions
-(void)itemOK{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
//    [self.itemAry release];
//    [itemDic release];
    [super dealloc];
}
@end
