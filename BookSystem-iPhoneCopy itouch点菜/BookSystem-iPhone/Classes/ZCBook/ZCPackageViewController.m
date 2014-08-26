//
//  PackageViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "ZCPackageViewController.h"
#import "BSDataProvider.h"
#import "ZCPackageCell.h"
#import "ZCPackItemViewController.h"
#import "CVLocalizationSetting.h"

@interface ZCPackageViewController ()

@end

@implementation ZCPackageViewController
@synthesize delegate;

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
    
    packageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44)];
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
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePackageItemAction:) name:@"ZCChangePackageItemNotification" object:nil];
    
}

#pragma mark -  UITableView Delegate & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"packageResultCell";    
    ZCPackageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[ZCPackageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
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
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dic = [dicInfo objectAtIndex:indexPath.row];
    NSString *packID = [dic objectForKey:@"PACKID"];
    NSString *item = [dic objectForKey:@"ITEM"];
    NSString *tag = [dic objectForKey:@"TAG"];
    
    BSDataProvider *dp = [[BSDataProvider alloc] init];
    NSArray *array = [dp getShiftFood_zc:item ofPackage:packID];
    
    if ([tag isEqualToString:@"Y"] && array != NULL) {
        
        ZCPackItemViewController *packItem = [[ZCPackItemViewController alloc] init];
        packItem.itemAry = (NSMutableArray *)array;
        [self.navigationController pushViewController:packItem animated:YES];
    }
}


#pragma mark - actions
- (void)packageOK{
    if ([self.delegate respondsToSelector:@selector(packOK:)]) {
        [self.delegate packOK:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];

    //刷新菜单也Table，显示已点数量用
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZCreloadTableNotification" object:nil];
}

#pragma mark - NSNotificationCenter
- (void)changePackageItemAction:(NSNotification *)notification{
    NSMutableDictionary *dic = (NSMutableDictionary *)[notification object];
    int i = 0;
    for (NSMutableDictionary * mut in dicInfo) {
        if ([[mut objectForKey:@"ITEM"] isEqual:[dic objectForKey:@"ITEM"]]) {
            [dic removeObjectForKey:@"ITEM"];
            [dic setObject:[mut objectForKey:@"ID"] forKey:@"ID"];
            [dic setObject:@"N" forKey:@"TAG"];
            [dic setObject:[dic objectForKey:@"SUBITEM"] forKey:@"ITEM"];
            [dic removeObjectForKey:@"SUBITEM"];
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
