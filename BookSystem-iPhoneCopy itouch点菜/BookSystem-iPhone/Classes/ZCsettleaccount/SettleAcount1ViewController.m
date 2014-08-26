//
//  BSLogViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "SettleAcount1ViewController.h"
#import "BSDataProvider.h"
#import "ZCQueryCell.h"
#import "CVLocalizationSetting.h"
#import "AppDelegate.h"
#import "ZCBSBookViewController.h"
#import "ZCChuckView.h"

@interface SettleAcount1ViewController ()

@end

@implementation SettleAcount1ViewController
@synthesize dicInfo,dicOrder;

- (void)dealloc{
    self.dicInfo = nil;
    self.dicOrder = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	langSetting = [CVLocalizationSetting sharedInstance];
    arySelectedFood = [[NSMutableArray alloc] init];
    [self addBGColor:nil];
    [self addNavBack];
    [self setNavTitle:[dicInfo objectForKey:@"table"]];
//    [self addNavButtonAndTitle:[dicInfo objectForKey:@"name"]];
    
    UITabBar *tabbar = [[UITabBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tabbar];
    [tabbar release];
    tabbar.delegate = self;
    
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
         tvFood = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44-20-44)];
         tabbar.frame = CGRectMake(0, ScreenHeight-44*2-20, ScreenWidth, 44);
     }else{
         tvFood = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-44-44)];
         tabbar.frame = CGRectMake(0, ScreenHeight-44*2, ScreenWidth, 44);
     }
    tvFood.backgroundColor = [UIColor whiteColor];
    tvFood.delegate = self;
    tvFood.dataSource = self;
    [self.view addSubview:tvFood];
    [tvFood release];
    
    NSString *push = [langSetting localizedString:@"Push Food"];
//    NSString *elide = [langSetting localizedString:@"Elide Food"];
    NSString *add = [langSetting localizedString:@"addFood"];
//    NSString *reElide = [langSetting localizedString:@"reCallElide"];
    NSString *chuck = [langSetting localizedString:@"chuck"];
    NSString *print = [langSetting localizedString:@"print"];
    
    NSArray *titles = [NSArray arrayWithObjects:push,chuck,add,print, nil];
    NSMutableArray *mut = [NSMutableArray array];
    for (int i=0;i<titles.count;i++){
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:nil image:nil tag:i];
        [mut addObject:item];
        [item release];
    }
    tabbar.items = mut;
    
    if ([tabbar respondsToSelector:@selector(setBackgroundImage:)]){
        [self generateImagesForTabBar:tabbar];
        
        [tabbar setBackgroundImage:[UIImage imageWithContentsOfFile:[@"BSTabBarBG.png" documentPath]]];
        [tabbar setSelectionIndicatorImage:[UIImage imageWithContentsOfFile:[@"BSTabBarSelectionBG.png" documentPath]]];
    }
    
    for (int i=0;i<titles.count;i++){
        float w = 320/titles.count;
        w = (int)w;
        UILabel *lbl = [UILabel createLabelWithFrame:CGRectMake(w*i, 0, w, 44) font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [tabbar addSubview:lbl];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text = [titles objectAtIndex:i];
    }
    
    [SVProgressHUD showWithStatus:@"正在获取账单"];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
}

- (void)loadData{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        
        NSDictionary *dict = [dp pQuery_zc:dicInfo];
        sw_dispatch_sync_on_main_thread(^{
        if ([dict objectForKey:@"Result"]){
            NSString *title,*msg;
            title = @"查询账单失败";
            msg = [dict objectForKey:@"Message"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
            
        }else{
            self.dicOrder = dict;
            
            NSArray *ary = [self.dicOrder objectForKey:@"account"];
            NSMutableArray *mut = [NSMutableArray array];
            
            for (int i=0;i<[ary count];i++){
                NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:[ary objectAtIndex:i]];
                [mutdict setObject:[NSNumber numberWithInt:100+i] forKey:@"FoodIndex"];
                
                [mut addObject:mutdict];
            }
            
            NSMutableDictionary *mutdict = [NSMutableDictionary dictionaryWithDictionary:self.dicOrder];
            [mutdict setObject:mut forKey:@"account"];
            
            self.dicOrder = [NSDictionary dictionaryWithDictionary:mutdict];
        }
        
        
            [SVProgressHUD dismiss];
            
            [tvFood reloadData];
            
            NSLog(@"Food List:%@",[dicOrder objectForKey:@"account"]);
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - viewsDelegate
-(void)dimissViews{
    if (vChuck && vChuck.superview) {
        [vChuck removeFromSuperview];
        vChuck = nil;
    }
    if (vPrint && vPrint.superview) {
        [vPrint removeFromSuperview];
        vPrint = nil;
    }
}
- (void)chuckOrderWithOptions:(NSMutableDictionary *)info{
    if (info) {
        NSString *tab = [[arySelectedFood objectAtIndex:0] objectForKey:@"num"];
        [info setValue:tab forKey:@"tab"];
        [NSThread detachNewThreadSelector:@selector(chuckFood:) toTarget:self withObject:info];
    }
    [self dimissViews];
}

- (void)chuckFood:(NSDictionary *)info{
    @autoreleasepool {
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSDictionary *dict = [dp pChuck:info];
        BOOL bSucceed = [[dict objectForKey:@"Result"] boolValue];
        NSString *title,*msg;
        if (bSucceed){
            title = [langSetting localizedString:@"ChuckSucceed"];//@"退菜成功";
            msg = nil;
            [arySelectedFood removeAllObjects];
        }else{
            title = [langSetting localizedString:@"ChuckFailed"];//@"退菜失败";
            msg = [dict objectForKey:@"Message"];
        }
        bs_dispatch_sync_on_main_thread(^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
        if (bSucceed){
            [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
        }
    }
}

#pragma mark - UITableView Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FoodCell";
    
    ZCQueryCell *cell = (ZCQueryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[ZCQueryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.dicInfo = [[dicOrder objectForKey:@"account"] objectAtIndex:indexPath.row];
    BOOL bInArray = NO;
    for (NSDictionary *dic in arySelectedFood) {
        NSDictionary *dic2 = [cell.dicInfo retain];
        NSString *foodIndex = [NSString stringWithFormat:@"%d",[[dic2 objectForKey:@"FoodIndex"] intValue]];
        NSString *foodIndexD = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"FoodIndex"] intValue]];
        if ([foodIndexD isEqualToString:foodIndex]){
            bInArray = YES;
            break;
        }
    }
    cell.bSelected = bInArray;
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[dicOrder objectForKey:@"account"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCQueryCell *cell = (ZCQueryCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL bInArray = NO;
     NSDictionary *foodIn = nil;
    for (NSDictionary *dic in arySelectedFood) {
        NSDictionary *dic2 = [cell.dicInfo retain];
        NSString *foodIndex = [NSString stringWithFormat:@"%d",[[dic2 objectForKey:@"FoodIndex"] intValue]];
        NSString *foodIndexD = [NSString stringWithFormat:@"%d",[[dic objectForKey:@"FoodIndex"] intValue]];
        if ([foodIndexD isEqualToString:foodIndex]){
            bInArray = YES;
            foodIn = dic;
            break;
        }
    }
    if (bInArray) {
        cell.bSelected = NO;
        [arySelectedFood removeObject:foodIn];
    }else{
        cell.bSelected = YES;
        [arySelectedFood addObject:cell.dicInfo];
    }
}

#pragma mark - UITabar

- (void)generateImagesForTabBar:(UITabBar *)tabbar{
    if (1 || ![[NSFileManager defaultManager] fileExistsAtPath:[@"BSTabBarBG.png" documentPath]]){
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        
        float w = 320/tabbar.items.count;
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = imgv.bounds;
        [imgv.layer addSublayer:gradientLayer];
        [gradientLayer release];
        
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:.98 green:.33 blue:.35 alpha:1].CGColor,(id)[UIColor colorWithRed:.55 green:0 blue:.04 alpha:1].CGColor,nil];
        gradientLayer.startPoint = CGPointZero;
        gradientLayer.endPoint = CGPointMake(0.0, 1);
        
        for (int i=1;i<tabbar.items.count;i++){
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(i*w, 0, 1, 44)];
            line.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
            [imgv addSubview:line];
            [line release];
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 44),YES,0.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [imgv.layer renderInContext:ctx];
        UIImage *imgC = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        NSData *data = UIImagePNGRepresentation(imgC);
        [data writeToFile:[@"BSTabBarBG@2x.png" documentPath] atomically:NO];
        [data writeToFile:[@"BSTabBarBG.png" documentPath] atomically:NO];
        
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:.98 green:.79 blue:.45 alpha:1].CGColor,(id)[UIColor colorWithRed:.84 green:.3 blue:.13 alpha:1].CGColor,nil];
        gradientLayer.startPoint = CGPointZero;
        gradientLayer.endPoint = CGPointMake(0.0, 1);
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320/tabbar.items.count, 44),YES,0.0);
        ctx = UIGraphicsGetCurrentContext();
        [imgv.layer renderInContext:ctx];
        imgC = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [imgv release];
        
        data = UIImagePNGRepresentation(imgC);
        [data writeToFile:[@"BSTabBarSelectionBG@2x.png" documentPath] atomically:NO];
        [data writeToFile:[@"BSTabBarSelectionBG.png" documentPath] atomically:NO];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    switch (item.tag) {
            
        case 0:{//   推菜
            int count = [arySelectedFood count];
            if (count <= 0) {
                [SVProgressHUD showErrorWithStatus:@"没有选择菜品"];
            }else{
                [SVProgressHUD showWithStatus:[langSetting localizedString:@"push"]];
                NSString *tab = [dicOrder objectForKey:@"tab"];
                if ([arySelectedFood count] > 0) {
                    NSString *num = [[arySelectedFood lastObject] objectForKey:@"num"];
                    [arySelectedFood removeLastObject];
                    NSDictionary *dicR = [NSDictionary dictionaryWithObjectsAndKeys:num,@"num",tab,@"tab", nil];
                    [NSThread detachNewThreadSelector:@selector(callPubitem:) toTarget:self withObject:dicR];
                }
            }
            
        }
            break;
        case 1:{//   退菜
            int count = [arySelectedFood count];
            if (count <= 0) {
                [SVProgressHUD showErrorWithStatus:@"没有选择菜品"];
            }else{
                if (vChuck){
                    [vChuck removeFromSuperview];
                    vChuck = nil;
                }
                vChuck = [[ZCChuckView alloc] initWithFrame:CGRectMake(0, 0, 280, 320)];
                vChuck.delegate = self;
                vChuck.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-100);
                vChuck.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                [self.view addSubview:vChuck];
                [vChuck release];
                [UIView animateWithDuration:0.5f animations:^(void) {
                    vChuck.transform = CGAffineTransformIdentity;
                }];
            }
        }
            break;
            
        case 2:{//   加菜
            [self addFood];
        }
            break;
            
        case 3:{//   打印单据
//            vPrint = [[BSPrintQueryView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
//            vPrint.delegate = self;
////            vPrint.center = CGPointMake(ScreenWidth/2, 150);
//            [self.view addSubview:vPrint];
//            [vPrint release];
//            [vPrint firstAnimation];
//            vPrint.center = CGPointMake(ScreenWidth/2, 150);
            
            
            vPrint = [[BSPrintQueryView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
            vPrint.delegate = self;
            vPrint.center = CGPointMake(ScreenWidth/2, ScreenHeight/2-130);
            vPrint.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            [self.view addSubview:vPrint];
            [vPrint release];
            [UIView animateWithDuration:0.5f animations:^(void) {
                vPrint.transform = CGAffineTransformIdentity;
            }];
        }
            break;
            
        default:
            break;
    }
}

//催菜
-(void)callPubitem1:(NSDictionary *)dicInfo{
    @autoreleasepool {
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSDictionary *dic = [db pGogo:dicInfo];
        if ([[dic objectForKey:@"Result"] boolValue]) {
            [SVProgressHUD showWithStatus:[langSetting localizedString:@"SuccessRefresh"] maskType:SVProgressHUDMaskTypeClear];
            [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"Message"]];
        }
    }
}

- (void)callPubitem:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pGogo:info];
    
    BOOL bSuceed = [[dict objectForKey:@"Result"] boolValue];
    NSString *title,*msg;
    title = nil;
    msg = nil;
    if (bSuceed) {
        if (![arySelectedFood count] > 0) {
            title = @"催菜成功完成";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];

            [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
        } else {
            NSString *tab = [dicOrder objectForKey:@"tab"];
            NSString *num = [[arySelectedFood lastObject] objectForKey:@"num"];
            [arySelectedFood removeLastObject];
            NSDictionary *dicR = [NSDictionary dictionaryWithObjectsAndKeys:num,@"num",tab,@"tab", nil];
            [NSThread detachNewThreadSelector:@selector(callPubitem:) toTarget:self withObject:dicR];
        }
    } else {
        title = @"催菜失败";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    }
    
    [pool release];
}

//加菜
-(void)addFood{
    [[NSUserDefaults standardUserDefaults] setObject:@"ZCaddFood" forKey:@"ZCenterState"];
    [[NSUserDefaults standardUserDefaults] setObject:[dicInfo objectForKey:@"table"] forKey:@"tableNum"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    ZCBSBookViewController *vcBook = [[ZCBSBookViewController alloc] init];
//    UIViewController *menuCtrl = [(AppDelegate *)([[UIApplication sharedApplication] delegate]) menuCtrl];
//    [menuCtrl setRootController:vcBook animated:YES];
    [self.navigationController pushViewController:vcBook animated:YES];
}

#pragma mark - PrintQueryDelegate
- (void)printQueryWithOptions:(NSDictionary *)info{
    [vPrint removeFromSuperview];
    vPrint = nil;
    
    if (!info)
        return;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:info];
    [dic setObject:[dicOrder objectForKey:@"tab"] forKey:@"tab"];
    
    [NSThread detachNewThreadSelector:@selector(printQuery:) toTarget:self withObject:dic];
}

- (void)printQuery:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSDictionary *dict = [dp pPrintQuery:info];
    
    NSString *msg;
    if ([[dict objectForKey:@"Result"] boolValue])
        msg = [langSetting localizedString:@"PrintSucceed"];
    else
        msg = [langSetting localizedString:@"PrintFailed"];
    
    bs_dispatch_sync_on_main_thread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    });
    
    [pool release];
}
@end
