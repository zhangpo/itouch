//
//  WaitItemViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-8.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "WaitItemViewController.h"
#import "CVLocalizationSetting.h"
#import "WaitItemCell.h"
#import "BSDataProvider.h"
#import "BSTableViewController.h"

@interface WaitItemViewController ()

@end

@implementation WaitItemViewController
@synthesize aryWaitFood,dicInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        aryWaitFood = [[NSArray array] retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    langSetting = [CVLocalizationSetting sharedInstance];
    [self addBGColor:nil];
	[self addNavBack];
    [self setNavTitle:[langSetting localizedString:@"Wait order details"]];
    [self addNavButtonWithTitle:[langSetting localizedString:@"The permanent Table"] atPosition:SWNavItemPositionRight action:@selector(changeWaitTable)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        tvWaitItem = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-20) style:UITableViewStylePlain];
    }else{
        tvWaitItem = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44) style:UITableViewStylePlain];
    }
    tvWaitItem.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvWaitItem.delegate = self;
    tvWaitItem.dataSource = self;
    [self.view addSubview:tvWaitItem];
    [tvWaitItem release];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"waitItemTableCell";
    WaitItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[WaitItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    NSDictionary *dic = [aryWaitFood objectAtIndex:indexPath.row];
    cell.dicInfo = dic;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [aryWaitFood count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)setAryWaitFood:(NSArray *)Info{
    if (aryWaitFood != Info) {
        [aryWaitFood release];
        aryWaitFood = [[NSArray arrayWithArray:Info] retain];
    }
    [tvWaitItem reloadData];
}

-(void)setDicInfo:(NSDictionary *)Info{
    if (dicInfo != Info) {
        [dicInfo release];
        dicInfo = [[NSDictionary dictionaryWithDictionary:Info] retain];
    }
    [tvWaitItem reloadData];
}

#pragma mark - changeWaitTableView
-(void)dismissViews{
    if (changeView){
        [changeView removeFromSuperview];
        changeView = nil;
    }
}
-(void)changeWaitTable{
    if (changeView){
        [changeView removeFromSuperview];
        changeView = nil;
    }
    [[NSUserDefaults standardUserDefaults] setValue:[dicInfo objectForKey:@"tableNum"] forKey:@"phone2"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    changeView = [[ChangeWaitTableView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
    changeView.delegate = self;
    changeView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-120);
    changeView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [self.view addSubview:changeView];
    [changeView release];
    [UIView animateWithDuration:0.5f animations:^(void) {
        changeView.transform = CGAffineTransformIdentity;
    }];
}

- (void)ChangeWaitTableWithOptions:(NSDictionary *)info{
    if (info) {
        [NSThread detachNewThreadSelector:@selector(changeWaitTable:) toTarget:self withObject:info];
    }
    [self dismissViews];
}

-(void)changeWaitTable:(NSMutableDictionary *)info{
    @autoreleasepool {
        [info setValue:[dicInfo objectForKey:@"orderId"] forKey:@"orderID"];
        NSDictionary *dicWaitList = [[BSDataProvider sharedInstance] changeTableNum:info];
        if ([[dicWaitList objectForKey:@"Result"] boolValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[dicWaitList objectForKey:@"Message"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Message"] message:[dicWaitList objectForKey:@"Message"] delegate:self cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
