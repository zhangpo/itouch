//
//  BSSearchViewController.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-25.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "BSBookViewController.h"
#import "BSDataProvider.h"
#import "BSOrderFoodViewController.h"
#import "BSOrderViewController.h"
#import "BSDataProvider.h"
#import "LeftMenuTypeViewController.h"
#import "BSBookCell.h"
#import "PackageViewController.h"
#import "PackAdditionsViewController.h"
#import "CVLocalizationSetting.h"
#import "AppDelegate.h"
#import "SearchCoreManager.h"
#import "ContactPeople.h"
#import "LeftClassTableView.h"

@interface BSBookViewController ()

@end

@implementation BSBookViewController
@synthesize aryResult,strPriceKey,strUnitKey,aryAddition;
@synthesize searchByName,tfInput,contactDic,searchBar;

static bool boolSearch = NO;
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.aryResult = nil;
    self.searchByName = nil;
    self.contactDic = nil;
    [allPriceLable release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [NSThread detachNewThreadSelector:@selector(soldOut) toTarget:self withObject:nil];//沽清
    
    self.navigationController.delegate=self;
    //获取类别
    BSDataProvider *dataPro = [BSDataProvider sharedInstance];
    classArray = [[NSMutableArray alloc] init];
    classArray = [[dataPro getClassList] retain];
    
    //左边类
    leftClass = [[LeftClassTableView alloc] init];
    self.aryResult = [NSMutableArray array];
    
    //搜索按钮
    butSerachFood = [UIButton buttonWithType:UIButtonTypeCustom];
    [butSerachFood addTarget:self action:@selector(buttonSerachClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *img = [UIImage imageNamed:@"butSearch"];
    UIEdgeInsets insets1 = UIEdgeInsetsMake(1, 1, 28, 10);
    UIImage *imgRe = [img resizableImageWithCapInsets:insets1];
    butSerachFood.frame = CGRectMake(0, 0, kLeftTableWidth, 30);
    [butSerachFood setBackgroundImage:imgRe forState:UIControlStateNormal];
    [self.view addSubview:butSerachFood];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        leftClass.frame = CGRectMake(0, 30, kLeftTableWidth-2, ScreenHeight-44-20-30);
       tvResult = [[UITableView alloc] initWithFrame:CGRectMake(kLeftTableWidth, 0, ScreenWidth-kLeftTableWidth, ScreenHeight-44-20) style:UITableViewStylePlain];
        imgSeparator = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftTableWidth-2, 0, 2, ScreenHeight-44-20)];
    }else{
        leftClass.frame = CGRectMake(0, 30, kLeftTableWidth-2, ScreenHeight-44-30);
        tvResult = [[UITableView alloc] initWithFrame:CGRectMake(kLeftTableWidth, 0, ScreenWidth-kLeftTableWidth, ScreenHeight-44) style:UITableViewStylePlain];
        imgSeparator = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftTableWidth-2, 0, 2, ScreenHeight-44)];
    }
    
    //添加单击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
    tap.delegate = self;
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [tvResult addGestureRecognizer:tap];
    [tap release];
    
    //中间分割线
    [imgSeparator setImage:[UIImage imageNamed:@"separator"]];
    [self.view addSubview:imgSeparator];
    [imgSeparator release];
    
    //菜品table
    tvResult.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvResult.delegate = self;
    tvResult.dataSource = self;
    [self.view addSubview:tvResult];
    [tvResult release];
    
    [self.view addSubview:leftClass];
    
    UIView *v= [[UIView alloc] init];
    v.frame = CGRectMake(0, 0, ScreenWidth-kLeftTableWidth, 30);
    v.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    tvResult.tableFooterView = v;
    //动画
    butMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img1 = [UIImage imageNamed:@"money"];
    CGFloat top = 1; // 顶端盖高度
    CGFloat bottom = 41 ; // 底端盖高度
    CGFloat left = 20; // 左端盖宽度
    CGFloat right = 30; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    UIImage *imgR = [img1 resizableImageWithCapInsets:insets];
    [butMenu setBackgroundImage:imgR forState:UIControlStateNormal];
//    [butMenu setTitle:@"￥:100元" forState:UIControlStateNormal];
     butMenu.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    butMenu.tag = 55;
    butMenu.hidden = YES;
    
    allPriceLable = [[RTLabel alloc] init];
    allPriceLable.textColor = [UIColor whiteColor];
    allPriceLable.backgroundColor = [UIColor clearColor];
    allPriceLable.font = [UIFont systemFontOfSize:12.0f];
    allPriceLable.hidden = YES;
    allPriceLable.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickPrice:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [allPriceLable addGestureRecognizer:singleTap];
    [singleTap release];
    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrdered)];
//    [allPriceLable addGestureRecognizer:singleTap];
//    [singleTap release];
//    [UIView insertSubview:allPriceLable aboveSubview:butMenu];
    
    imgMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shopCart"]];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        imgMenu.frame = CGRectMake(ScreenWidth-25, ScreenHeight-32-44-20, 25, 25);
    }else{
        imgMenu.frame = CGRectMake(ScreenWidth-25, ScreenHeight-32-44, 25, 25);
    }
    [self.view addSubview:butMenu];
    [self.view addSubview:imgMenu];
    [self.view addSubview:allPriceLable];
    imgMenu.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrdered)];
    [imgMenu addGestureRecognizer:singleTap1];
    [singleTap1 release];
    [imgMenu release];
    
    [self addCount];//计算总价格
    [self getTypeFoodList:-1]; //页面初始化的时候加载所有的菜品
    
    //搜索的背景视图
    imgv = [[UIImageView alloc] initWithFrame:CGRectZero];
    [imgv setImage:[UIImage imageNamed:@"padbg.png"]];
    imgv.userInteractionEnabled = YES;
    imgv.hidden = YES;
    [self.view addSubview:imgv];
    [imgv release];
    
    UIImageView *imgJT = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jiantou_you"]];
    imgJT.frame = CGRectMake(ScreenWidth-10, (ScreenHeight-44)/2-140, 10, 180);
    [self.view addSubview:imgJT];
    [imgJT release];
    
//    self.tfInput = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 260, 32)];
//    self.tfInput.borderStyle = UITextBorderStyleRoundedRect;
//    self.tfInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    self.tfInput.placeholder = [langSetting localizedString:@"Search"]; //搜索
//    [imgv addSubview:self.tfInput];
//    self.tfInput.delegate = self;
//    self.tfInput.hidden = YES;
//    [self.tfInput release];
//    
//    SWInputView *iw = [[[SWInputView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 243)] autorelease];
//    iw.delegate = self;
////    tfInput.inputView = iw;
//    [self.tfInput resignFirstResponder];
    
    
    btnKeyBoard = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnKeyBoard setImage:[UIImage imageNamed:@"paddown.png"] forState:UIControlStateNormal];
    [btnKeyBoard setImage:[UIImage imageNamed:@"paddownsel.png"] forState:UIControlStateHighlighted];
    [btnKeyBoard sizeToFit];
    btnKeyBoard.frame = CGRectMake(280, 10, 35, 32);
    [btnKeyBoard addTarget:self action:@selector(updownClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgv addSubview:btnKeyBoard];
    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 310.0f, 44.0f)] autorelease];
    self.searchBar.frame = CGRectMake(10, 10, 260, 32);
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeDefault;
	self.searchBar.backgroundColor=[UIColor clearColor];
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"padbg.png"]];
	searchBar.translucent=YES;
	self.searchBar.placeholder=@"搜索";
	self.searchBar.delegate = self;
	self.searchBar.barStyle=UIBarStyleDefault;
    [imgv addSubview:self.searchBar];
    [self serach];//给第三方搜索插件赋值
    
//    btnOrdered = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnOrdered.frame = CGRectMake(0, self.view.frame.size.height-51-44, 160, 51);
//    [btnOrdered setBackgroundImage:[UIImage imageNamed:@"BSBigTab.png"] forState:UIControlStateNormal];
//    [btnOrdered setBackgroundImage:[UIImage imageNamed:@"BSBigTabSelected.png"] forState:UIControlStateSelected];
//    [btnOrdered setTitleColor:[UIColor colorWithRed:.35 green:.18 blue:.04 alpha:1] forState:UIControlStateNormal];
//    [btnOrdered setTitle:@"附加项" forState:UIControlStateNormal];
//    btnOrdered.tag = 0;
//    [self.view addSubview:btnOrdered];
//    [btnOrdered addTarget:self action:@selector(additionClicked) forControlEvents:UIControlEventTouchUpInside];
//    btnOrdered.selected = YES;
//    
//    btnBook = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnBook.frame = CGRectMake(160, self.view.frame.size.height-51-44, 160, 51);
//    [btnBook setBackgroundImage:[UIImage imageNamed:@"BSBigTab.png"] forState:UIControlStateNormal];
//    [btnBook setBackgroundImage:[UIImage imageNamed:@"BSBigTabSelected.png"] forState:UIControlStateSelected];
//    [btnBook setTitleColor:[UIColor colorWithRed:.35 green:.18 blue:.04 alpha:1] forState:UIControlStateNormal];
//    [btnBook setTitle:@"发送" forState:UIControlStateNormal];
//    btnBook.tag = 1;
//    [self.view addSubview:btnBook];
//    btnBook.selected = YES;
//    [btnBook addTarget:self action:@selector(sendClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"ChangeTypeNotification" object:nil];
    
    //刷新Table
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadTableNotification" object:nil];
    [self reloadTable];
    //确认点菜事件通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePackageAction:) name:@"ChangePackageNotification" object:nil];
    
    //键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - actions
//键盘显示 布局改变
-(void)keyboardWillShow
{
    btnKeyBoard.selected = NO;
    [btnKeyBoard setImage:[UIImage imageNamed:@"paddown.png"] forState:UIControlStateNormal];
    [btnKeyBoard setImage:[UIImage imageNamed:@"paddownsel.png"] forState:UIControlStateHighlighted];
    
}

//键盘隐藏  布局改变
-(void)keyboardWillHide
{
    btnKeyBoard.selected = YES;
    [btnKeyBoard setImage:[UIImage imageNamed:@"padup.png"] forState:UIControlStateNormal];
    [btnKeyBoard setImage:[UIImage imageNamed:@"padupsel.png"] forState:UIControlStateHighlighted];
}

#pragma mark Notification

-(void)reloadTable{
    
    [self addCount];
    [self getTypeFoodList:-1]; //页面初始化的时候加载所有的菜品
    [tvResult reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLeftTable" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadRigthtTableNotification" object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)serach{
    [[SearchCoreManager share] Reset];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.contactDic = dic;
    [dic release];
    
    NSMutableArray *nameIDArray = [[NSMutableArray alloc] init];
    self.searchByName = nameIDArray;
    [nameIDArray release];
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    searchByResult = resultArray;
    [resultArray release];
    
    NSNumber *localID = 0;
    NSString *name,*itcope;
    int i = 0;
    for (NSMutableDictionary *dic in self.aryResult) {
        localID = [NSNumber numberWithInt:i];
         name = [dic objectForKey:@"DES"];
        itcope = [dic objectForKey:@"ITCODE"];
        [[SearchCoreManager share] AddContact:localID name:name phone:nil];
        [self.contactDic setObject:itcope forKey:localID];
        i++;
    }
}



//-(void)changePackageAction:(NSNotification *)notification{
//    NSMutableDictionary *mutDic = notification.object;
//    int i = 0;
//    for (NSMutableDictionary *dic in aryResult) {
//        if ([[dic objectForKey:@"PACKID"] isEqual:[mutDic objectForKey:@"PACKID"]]) {
//            [self addFood:mutDic byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
//            break;
//        }
//        i++;
//    }
//}

#pragma mark - Actions
//沽清
-(void)soldOut{
    @autoreleasepool {
        NSDictionary *dicSold = [NSDictionary dictionary];
        dicSold =  [[BSDataProvider sharedInstance] soldOut];
        if ([[dicSold objectForKey:@"Result"] boolValue]) {
            arySoldOut = [[dicSold objectForKey:@"soldOutList"] retain];
            [SVProgressHUD dismiss];
        }else{
            [SVProgressHUD showErrorWithStatus:[dicSold objectForKey:@"Message"]];
        }
    }
}

//已点菜品事件
- (void)showOrdered{
    BSOrderViewController *vcOrder = [[BSOrderViewController alloc] init];
    [self.navigationController pushViewController:vcOrder animated:YES];
    [vcOrder release];
}

//已点菜品事件   单机总价格
-(void)tapClickPrice:(UITapGestureRecognizer *)tap{
    BSOrderViewController *vcOrder = [[BSOrderViewController alloc] init];
    [self.viewController.navigationController pushViewController:vcOrder animated:YES];
    [vcOrder release];
}

- (void)packOK:(PackageViewController *)packView{
    NSMutableDictionary *mutDic = packView.mutAry;
    if (mutDic == NULL) {
        mutDic = packView.packInfo2;
    }
    [self addFood:mutDic byCount:[NSString stringWithFormat:@"%.1f",1.0f]];
}

//键盘改变的通知 。。。
- (void)orderChanged{
    [tvResult reloadData];
}

- (void)orderClicked{
    BSOrderFoodViewController *vcOrder = [[BSOrderFoodViewController alloc] init];
    [self.navigationController pushViewController:vcOrder animated:YES];
    [vcOrder release];
}

- (void)additionClicked{
    
}

//发送
- (void)sendClicked{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入台号" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the ramadhin"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert show];
    [alert release];
}

- (void)buttonClicked:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.tag==0)
        btnBook.selected = !btnOrdered;
    else
        btnOrdered.selected = !btnBook;
}

-(void)buttonSerachClicked:(UIButton *)btn{
    if (boolSearch) {
        imgv.hidden = YES;
        butSerachFood.frame = CGRectMake(0, 0, kLeftTableWidth-2, 30);
        leftClass.frame = CGRectMake(0, 30, kLeftTableWidth-2, ScreenHeight-44-20-30);
        tvResult.frame = CGRectMake(kLeftTableWidth, 0, ScreenWidth-kLeftTableWidth, ScreenHeight-44-20);
        [self.searchBar resignFirstResponder];
        boolSearch = NO;
    }else{
        imgv.hidden = NO;
        butSerachFood.frame = CGRectMake(0, 50, kLeftTableWidth-2, 30);
        imgv.frame = CGRectMake(0, 0, ScreenWidth, 50);
        tvResult.frame = CGRectMake(kLeftTableWidth, 50, ScreenWidth-kLeftTableWidth, self.view.frame.size.height-44);
        leftClass.frame = CGRectMake(0, 50+30, kLeftTableWidth-2, self.view.frame.size.height-44);
        boolSearch = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Send Food
- (NSArray *)seperatedByType:(NSArray *)foods{
    NSMutableDictionary *mut = [NSMutableDictionary dictionary];
    for (int i=0;i<foods.count;i++){
        NSDictionary *dict = [foods objectAtIndex:i];
        BOOL ispack = [[dict objectForKey:@"ISTC"] boolValue];
        if (ispack){
            if (![mut objectForKey:@"pack"]){
                [mut setObject:[NSMutableArray array] forKey:@"pack"];
            }
            
            [[mut objectForKey:@"pack"] addObject:dict];
        }else{
            NSString *classid = [[dict objectForKey:@"food"] objectForKey:@"CLASS"];
            
            if (![mut objectForKey:classid]){
                [mut setObject:[NSMutableArray array] forKey:classid];
            }
            
            [[mut objectForKey:classid] addObject:dict];
        }
    }
    
    NSMutableArray *mutary = [NSMutableArray array];
    for (NSString *key in mut.allKeys){
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[mut objectForKey:key],@"foods",key,@"classid", nil];
        [mutary addObject:dic];
    }
    return [NSArray arrayWithArray:mutary];
}

- (void)sendOrderWithOptions:(NSDictionary *)info{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *aryMut = [NSMutableArray array];
    NSArray *ary = [self seperatedByType:[dp orderedFood]];
    
    
    for (int i=0;i<[ary count];i++){
        NSArray *foods = [[ary objectAtIndex:i] objectForKey:@"foods"];
        for (int j=0;j<foods.count;j++){
            [aryMut addObject:[foods objectAtIndex:j]];
        }
    }
    
    NSDictionary *userinfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
    
    NSDictionary *accountinfo = [NSDictionary dictionaryWithObjectsAndKeys:[userinfo objectForKey:@"username"],@"user",[userinfo objectForKey:@"password"],@"pwd", nil];

    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:info];
    [mutDic setValuesForKeysWithDictionary:accountinfo];
//    if (self.aryCommon){
//        [mutDic setValue:self.aryCommon forKey:@"common"];
//        self.strUser = [info objectForKey:@"user"];
//        [mutDic setValue:[info objectForKey:@"user"] forKey:@"user"];
//        [mutDic setValue:[info objectForKey:@"pwd"] forKey:@"pwd"];
//    }
    
    [SVProgressHUD showWithStatus:[langSetting localizedString:@"Are uploading Food"]];
    if ([aryMut count]>0)
        [self sendOrder:[NSDictionary dictionaryWithObjectsAndKeys:aryMut,@"ary",mutDic,@"options", nil]];
    else
        [self sendOrder:[NSDictionary dictionaryWithObjectsAndKeys:[dp orderedFood],@"ary",mutDic,@"options", nil]];
}

- (void)sendOrder:(NSDictionary *)info{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    langSetting = [CVLocalizationSetting sharedInstance];
    
    NSArray *ary = [info objectForKey:@"ary"];
    NSDictionary *options = [info objectForKey:@"options"];
    
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSString *cmd = [dp pSendTab:ary options:options];
    
    [self uploadFood:cmd];
    
    [pool release];
}

#pragma mark -  Upload Using FTP
-(void) requestCompleted:(WRRequest *) request{
    langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    BOOL bSucceed = YES;
    
    NSMutableArray *aryDelete = [NSMutableArray array];
    NSString *title;
    if (bSucceed){
        title = [langSetting localizedString:@"Send Succeeded"];//[langSetting localizedString:@"Send Succeeded"];//@"传菜成功";
        NSMutableArray *ary = [dp orderedFood];
        NSArray *sorted = [self seperatedByType:ary];
        for (int i=0;i<[sorted count];i++){
            NSArray *foods = [[sorted objectAtIndex:i] objectForKey:@"foods"];
            for (int j=0;j<foods.count;j++){
                [aryDelete addObject:[NSNumber numberWithInt:[ary indexOfObject:[foods objectAtIndex:j]]]];
                    
            }
            
        }
        
//        if ([aryDelete count]>0){
//            for (int i=[aryDelete count]-1;i>=0;i--){
//                [ary removeObjectAtIndex:[[aryDelete objectAtIndex:i] intValue]];
//            }
//        }
//        else
        
            [ary removeAllObjects];
        
        [dp saveOrders];
        [tvResult reloadData];
    }
    else
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    sw_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showSuccessWithStatus:title];
    });
    
    //    [SVProgressHUD dismissWithSuccess:title afterDelay:2];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(void) requestFailed:(WRRequest *) request{
    
    //called after 'request' ends in error
    //we can print the error message
    NSLog(@"%@", request.error.message);
    [request release];
    
    langSetting = [CVLocalizationSetting sharedInstance];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //called if 'request' is completed successfully
    NSLog(@"%@ completed!", request);
    [request release];
    
    BOOL bSucceed = NO;
    
    NSMutableArray *aryDelete = [NSMutableArray array];
    NSString *title;
    if (bSucceed){
        title = [langSetting localizedString:@"Send Succeeded"];//@"传菜成功";
        NSMutableArray *ary = [dp orderedFood];
        NSArray *sorted = [self seperatedByType:ary];
        for (int i=0;i<[sorted count];i++){
            NSArray *foods = [[sorted objectAtIndex:i] objectForKey:@"foods"];
            for (int j=0;j<foods.count;j++){
                [aryDelete addObject:[NSNumber numberWithInt:[ary indexOfObject:[foods objectAtIndex:j]]]];
            }
            
        }
        
        if ([aryDelete count]>0){
            for (int i=[aryDelete count]-1;i>=0;i--){
                [ary removeObjectAtIndex:[[aryDelete objectAtIndex:i] intValue]];
            }
        }
        else
            [ary removeAllObjects];
        
        [dp saveOrders];
        [tvResult reloadData];
    }
    else
        title = [langSetting localizedString:@"Send Failed"];//@"传菜失败";
    
    //    [SVProgressHUD dismissWithError:title afterDelay:2];
    sw_dispatch_sync_on_main_thread(^{
        [SVProgressHUD showErrorWithStatus:title];
    });
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    //    [alert show];
    //    [alert release];
    
}

-(BOOL) shouldOverwriteFileWithRequest:(WRRequest *)request {
    
    //if the file (ftp://xxx.xxx.xxx.xxx/space.jpg) is already on the FTP server,the delegate is asked if the file should be overwritten
    //'request' is the request that intended to create the file
    return YES;
    
}
- (void)uploadFood:(NSString *)str{
    sw_dispatch_sync_on_main_thread(^{
        NSDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerSettings"] objectForKey:@"ftp"];
        WRRequestUpload *uploader = [[WRRequestUpload alloc] init];
        uploader.delegate = self;
        uploader.hostname = [dict objectForKey:@"ip"];
        uploader.username = [dict objectForKey:@"username"];
        uploader.password = [dict objectForKey:@"password"];
        
        uploader.sentData = [str dataUsingEncoding:NSUTF8StringEncoding];
        

      NSString *filename = [NSString stringWithFormat:@"%@%lf",[NSString performSelector:@selector(UUIDString)],[[NSDate date] timeIntervalSince1970]];
        
        uploader.path = [NSString stringWithFormat:@"/orders/%@.order",[filename MD5]];
        
//        NSString *filename = [NSString stringWithFormat:@"%@%lf",[UIDevice currentDevice].uniqueIdentifier,[[NSDate date] timeIntervalSince1970]];
        
        
        uploader.path = [NSString stringWithFormat:@"/orders/%@.order",[filename MD5]];
        
        [uploader start];
    });
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag==301) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:[langSetting localizedString:@"OK"]]){
            NSString *table = [[alertView textFieldAtIndex:0] text];
            [dicUnit2 setObject:table forKey:@"UNITCUR2"];
            [self addFood:dicUnit2 byCount:[NSString stringWithFormat:@"%d",1]];
            [tvResult reloadData];
            [self performSelector:@selector(addShopFinished:) withObject:nil afterDelay:0.5f];
//            [self addToShow:indexPath cellx:lx celly:ly+50];
        }
    }
    
}

#pragma mark -  UITableView Delegate & Data Source

//以前用的显示已点菜品数量的方法，暂时没用
-(void)_everyOrderCount{
    //遍历将已点的菜品数量放入aryResult中
    BSDataProvider *db = [BSDataProvider sharedInstance];
    NSMutableArray *aryMutOrder1 = [db orderedFood];
    NSMutableArray *aryMutOrder = [NSMutableArray arrayWithArray:aryMutOrder1];
    [aryResultNew release];
    aryResultNew = nil;
    aryResultNew = [NSMutableArray arrayWithArray:self.aryResult];
    for (NSMutableDictionary *dic in aryResultNew) {
//        if ([[dic objectForKey:@"ISTC"] boolValue] && [dic count] >= 10) {
//            NSLog(@"%@",dic);
////            [dic removeObjectForKey:@"foods"];
//        }
        if ([dic objectForKey:@"orderCount"]) {
            [dic removeObjectForKey:@"orderCount"];
        }
    }
    for (NSDictionary *dicOrder in aryMutOrder) {
        for (int i = 0; i < [aryResultNew count]; i++) {
            NSMutableDictionary *dicResult = [aryResultNew objectAtIndex:i];
            if (![[dicOrder objectForKey:@"ISTC"] boolValue]) {
                if ([[[dicOrder objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:[dicResult objectForKey:@"ITCODE"]] && ![[dicResult objectForKey:@"ISTC"] boolValue]) {
                    if ([dicResult objectForKey:@"orderCount"]) {
                        int countResult = [[dicResult objectForKey:@"orderCount"] intValue];
                        int countOrder = [[dicOrder objectForKey:@"total"] intValue];
                        int countAdd = countResult + countOrder;
                        NSString *count = [NSString stringWithFormat:@"%d",countAdd];
                        [dicResult setValue:count forKey:@"orderCount"];
                    }else{
                        [dicResult setValue:[dicOrder objectForKey:@"total"] forKey:@"orderCount"];
                    }
                    [aryResultNew replaceObjectAtIndex:i withObject:dicResult];
                    break;
                }
            }else{
                if ([[dicOrder objectForKey:@"ITCODE"] isEqualToString:[dicResult objectForKey:@"ITCODE"]] && [[dicResult objectForKey:@"ISTC"] boolValue]) {
                    if ([dicResult objectForKey:@"orderCount"]) {
                        int countResult = [[dicResult objectForKey:@"orderCount"] intValue];
                        int countOrder = [[dicOrder objectForKey:@"total"] intValue];
                        int countAdd = countResult + countOrder;
                        NSString *count = [NSString stringWithFormat:@"%d",countAdd];
                        [dicResult setValue:count forKey:@"orderCount"];
                    }else{
                        [dicResult setValue:[dicOrder objectForKey:@"total"] forKey:@"orderCount"];
                    }
                }
                [aryResultNew replaceObjectAtIndex:i withObject:dicResult];
            }
        }
    }
    [aryResultNew retain];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FoodResultCell";
    BSBookCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[BSBookCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        cell.delegate = self;
    }
    cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    if ([self.searchBar.text length] <= 0) {
        NSMutableArray *aryCount = [NSMutableArray array];
        for (NSMutableDictionary *dic in self.aryResult) {
            NSLog(@"%@",[[classArray objectAtIndex:indexPath.section] objectForKey:@"GRP"]);
            if ([[dic objectForKey:@"CLASS"] integerValue] == [[[classArray objectAtIndex:indexPath.section] objectForKey:@"GRP"] intValue]) {
                [aryCount addObject:dic];
            }
        }
        cell.dicInfo = [aryCount objectAtIndex:indexPath.row];
        cell.arySoldOut = arySoldOut;
        return cell;
    }
    cell.dicInfo = [searchByResult objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *aryCount = [NSMutableArray array];
    if ([self.searchBar.text length] <= 0) {
        for (NSDictionary *dic in aryResult) {
            if ([[dic objectForKey:@"CLASS"] integerValue] == [[[classArray objectAtIndex:section] objectForKey:@"GRP"] intValue]) {
                [aryCount addObject:dic];
            }
        }
        return [aryCount count];
    }else{ //区分section做的循环
//        for (NSDictionary *dic in searchByResult) {
//            if ([[dic objectForKey:@"CLASS"] integerValue] == section+1) {
//                [aryCount addObject:dic];
//            }
//        }
//        return [aryCount count];
        return [searchByResult count];
        
    }
}


//section的数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    [self _everyOrderCount]; //计算已点菜品的数量
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLeftTable" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadRigthtTableNotification" object:nil];
     if ([self.searchBar.text length] <= 0) {
          return [classArray count];
     }
    return 1;
    /*  //筛选搜索出的菜品的种类
    NSMutableArray *aryMutC = [NSMutableArray array];
    for (NSDictionary *dicSection in searchByResult) {
        [aryMutC addObject:[dicSection objectForKey:@"CLASS"]];
    }

    searchClass = [NSMutableArray array];
    BOOL boDiff = YES;
    for (int i=0; i<[aryMutC count]; i++) {
        boDiff = YES;
        for (int j=0; j<[searchClass count]; j++) {
            if ([aryMutC[i] isEqualToString:searchClass[j]]) {
                boDiff = NO;
                break;
            }
        }
        if (boDiff){
            [searchClass addObject:aryMutC[i]];
        }
    }
    int z =[searchClass count];
     */
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *headerTitle;
    if ([self.searchBar.text length] <= 0) {
        headerTitle = [[classArray objectAtIndex:section] objectForKey:@"DES"];
    }else{
        int count = [searchByResult count];
        headerTitle = [NSString stringWithFormat:[[CVLocalizationSetting sharedInstance] localizedString:@"Search Conform"],count];
    }
    return headerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BSBookCell *cell = (BSBookCell *)[tableView cellForRowAtIndexPath:indexPath];
    for (NSString *sold in arySoldOut) {
        if ([[cell.dicInfo objectForKey:@"ITCODE"] isEqualToString:sold]) {
            [SVProgressHUD showErrorWithStatus:[langSetting localizedString:@"sellout"]];
            return;
        }
    }
    
    indexp2 = [indexPath retain];
    NSMutableArray *aryCount = [NSMutableArray array];
    if ([self.searchBar.text length] <= 0) {
        for (NSDictionary *dic in aryResult) {
            if ([[dic objectForKey:@"CLASS"] integerValue] == [[[classArray objectAtIndex:indexPath.section] objectForKey:@"GRP"] intValue]) {
                [aryCount addObject:dic];
            }
        }
        NSMutableDictionary *dic = [aryCount objectAtIndex:indexPath.row];
        if ([[dic objectForKey:@"ISTC"] intValue]==1) {
            [self detailButAction:cell];
            return;
        }
        //第二单位
        if ([[dic objectForKey:@"UNITCUR"] isEqualToString:@"2"]) {
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the second unit"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                dicUnit2 = [dic retain];
                UITextField *tfAlert = [alert textFieldAtIndex:0];
                tfAlert.keyboardType = UIKeyboardTypeNumberPad;
                alert.delegate = self;
                alert.tag = 301;
                [alert show];
                [alert release];
            });
            
        }else{
            [self addFood:dic byCount:[NSString stringWithFormat:@"%d",1]];
            [tvResult reloadData];
            [self addToShow:indexPath cellx:lx celly:ly+50];
        }
    }else{
        NSMutableDictionary *dic =  [NSMutableDictionary dictionaryWithDictionary:[searchByResult objectAtIndex:indexPath.row]];
        if ([[dic objectForKey:@"ISTC"] intValue]==1) {
            [self detailButAction:cell];
            return;
        }
        //第二单位
        if ([[dic objectForKey:@"UNITCUR"] isEqualToString:@"2"]) {
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Please enter the second unit"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles:[langSetting localizedString:@"OK"], nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                alert.delegate = self;
                dicUnit2 = [dic retain];
                alert.tag = 301;
                [alert show];
                [alert release];
            });
            
        }else{
            [self addFood:dic byCount:[NSString stringWithFormat:@"%d",1]];
            [tvResult reloadData];
            [self addToShow:indexPath cellx:lx celly:ly+50];
        }
    }
}


- (BOOL)_recursion:(NSString *)item TimeCount:(NSString *)timeCount{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    
    for (NSDictionary *food in ary) {
        if ([[food objectForKey:@"OrderTimeCount"] isEqual:timeCount]) {
            for (NSMutableDictionary *dic2 in [food objectForKey:@"foods"]) {
                if ([[dic2 objectForKey:@"ITEM"] isEqual:item] && ![dic2 objectForKey:@"addition"]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

-(NSString *)_timeCount:(NSString *)packID{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    NSString *str = @"-1";
    for (NSDictionary *food in ary) {
        if ([[food objectForKey:@"ITCODE"] isEqual:packID]) {
            for (NSMutableDictionary *dic2 in [food objectForKey:@"foods"]) {
                if ([dic2 objectForKey:@"addition"]) {
                    str = @"-1";
                    break;
                }else{
                    str = [food objectForKey:@"OrderTimeCount"];
                }
            }
        }
    }
    return str;
}
-(NSString *)addTCPrice:(NSString *)itcode{
    //计算子菜品总价格
    float addPrice1 = 0;
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *mutAry = [dp getPackage:itcode];
    
    NSMutableArray *oldInfo = [NSMutableArray arrayWithArray:mutAry];
    NSMutableArray *a = [NSMutableArray array];
    for (NSMutableDictionary *mutD in oldInfo) {
        if ([[mutD objectForKey:@"defualtS"] isEqualToString:@"1"]) {
            NSString *tag = [mutD objectForKey:@"PRODUCTTC_ORDER"];
            [a addObject:tag];
        }
    }
    NSMutableArray *aryNew = [NSMutableArray array];
    for (NSMutableDictionary *mutD in oldInfo) {
        for (NSString *tag in a) {
            if ([[mutD objectForKey:@"PRODUCTTC_ORDER"] isEqualToString:tag]) {
                [mutD setObject:@"Y" forKey:@"TAG"];
            }
        }
        if ([[mutD objectForKey:@"defualtS"] isEqualToString:@"0"]) {
            [aryNew addObject:mutD];
        }
    }
    for (NSDictionary *dic in aryNew) {
        addPrice1 = addPrice1 + [[dic objectForKey:@"PRICE1"] floatValue];;
    }
    NSString *price = [NSString stringWithFormat:@"%.1f",addPrice1];
    
    return price;
}

- (void)addFood:(NSMutableDictionary *)foodInfo byCount:(NSString *)count{
    NSString *itcode = [foodInfo objectForKey:@"ITCODE"];
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *ary = [dp orderedFood];
    BOOL ISTC = [[foodInfo objectForKey:@"ISTC"] boolValue];
    NSString *packID = [foodInfo objectForKey:@"ITCODE"];
    BOOL bpackAge = NO;
    BOOL bpack = NO;
    if (ISTC) {  //套餐的处理
        
//        NSString *price = [self addTCPrice:[foodInfo objectForKey:@"ITCODE"]];
//        [foodInfo setValue:price forKey:@"PRICE"];
        NSMutableArray *ay = [foodInfo objectForKey:@"foods"];
        if (![ay count] > 0) {//直接点击套餐，不进入详情页面的时候，先根据套餐ID查询套餐子菜品
            NSString *sqlStr = [NSString stringWithFormat:@"'%@' and defualtS = 0",packID];
            BSDataProvider *dp = [BSDataProvider sharedInstance];
            NSMutableArray *mutAry = [dp getPackageWhere:sqlStr];
            [foodInfo setValue:mutAry forKey:@"foods"];
            mutAry = [self tcMonetyDetail:foodInfo]; //替换子菜品价格
            [foodInfo setValue:mutAry forKey:@"foods"];
            ay = mutAry;
            [mutAry release];
        }else{//详情页面替换子菜品价格
            NSMutableArray *mutAry = [self tcMonetyDetail:foodInfo]; //替换子菜品价格
            [foodInfo setValue:mutAry forKey:@"foods"];
        }
        
//        foodInfo = [self tcMonetyMode:foodInfo];//替换套餐价格
        
        NSString *timeCount = [self _timeCount:packID];
        
        for (NSDictionary *f in ay) {
          bpack = [self _recursion:[f objectForKey:@"ITEM"] TimeCount:timeCount];
            if (!bpack) {
                bpack = NO;
                break;
            }
        }
        
        for (NSDictionary *food in ary) {
            if ([[food objectForKey:@"ITCODE"] isEqualToString:packID] && bpack
                && [[food objectForKey:@"OrderTimeCount"] isEqual:timeCount]){                bpackAge = YES;
                float total = [[food objectForKey:@"total"] floatValue];
                total += [count floatValue];
                if (total>0){
                    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:food];
                    [mut setObject:[NSString stringWithFormat:@"%.1f",total] forKey:@"total"];
                    [ary replaceObjectAtIndex:[ary indexOfObject:food] withObject:mut];
                }else
                    [ary removeObject:food];
                
                [dp saveOrders];
                break;
            }
        }
        
        
        if (!bpackAge && [count floatValue]>0){
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:foodInfo];
            [dict setObject:count forKey:@"total"];
            
            if (self.aryAddition)
                [dict setObject:aryAddition forKey:@"addition"];
            
            if (self.strUnitKey){
                [dict setObject:strUnitKey forKey:@"unitKey"];
                [dict setObject:strPriceKey forKey:@"priceKey"];
            }
            
            [dp orderFood:dict];
            
            self.strUnitKey = @"UNIT";
            self.strPriceKey = @"PRICE";
            
        }
    }else{  //普通菜品的处理
    
    BOOL bFinded = NO;
    
    for (NSDictionary *food in ary){
        if (![food objectForKey:@"addition"]
            && ![[food objectForKey:@"ISTC"] boolValue]
            && [[[food objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:itcode]&&![[[food objectForKey:@"food"] objectForKey:@"UNITCUR"] isEqualToString:@"2"]){
            bFinded = YES;
            float total = [[food objectForKey:@"total"] floatValue];
            total += [count floatValue];
            
            if (total>0){
                NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:food];
                [mut setObject:[NSString stringWithFormat:@"%.1f",total] forKey:@"total"];
                [ary replaceObjectAtIndex:[ary indexOfObject:food] withObject:mut];
            }else
                [ary removeObject:food];
            
            [dp saveOrders];
            break;
        }
    }
    
    
    if (!bFinded && [count floatValue]>0){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:foodInfo forKey:@"food"];
        [dict setObject:count forKey:@"total"];
        if (self.aryAddition)
            [dict setObject:aryAddition forKey:@"addition"];
        
        if (self.strUnitKey){
            [dict setObject:strUnitKey forKey:@"unitKey"];
            [dict setObject:strPriceKey forKey:@"priceKey"];
        }
        
        [dp orderFood:dict];
    
        self.strUnitKey = @"UNIT";
        self.strPriceKey = @"PRICE";
    }
    }

//    [SVProgressHUD showSuccessWithStatus:[langSetting localizedString:@"Order Succeeded"]];
}

#pragma mark - 变价套餐
//替换子菜品价格
-(NSMutableArray *)tcMonetyDetail:(NSMutableDictionary *)info{
    NSString *tc = [info objectForKey:@"TCMONEYMODE"];
    
    //计算子菜品总价格
    float detailPrice = [self _tcAddDetailPrice:[info objectForKey:@"foods"]];//计算默认的详细菜品的总价格
    //    NSString *tcdetailPrice = [NSString stringWithFormat:@"%.1f",detailPrice];
    float tcPrice = [[info objectForKey:@"PRICE"] floatValue];
    float TCZZPirce;
    NSMutableArray *aryDetailFood = nil;
    if ([tc isEqualToString:@"1"]) {  //方式一
        aryDetailFood = [[NSMutableArray alloc] init];
        TCZZPirce = tcPrice;
        float b1 = 0;
        //将套餐的价格平分给每一个子菜品
        for (NSMutableDictionary *dicFood in [info objectForKey:@"foods"]) {
            float a1 = [[dicFood objectForKey:@"PRICE1"] floatValue]*tcPrice/detailPrice;
            float az = a1;
            b1 = b1 + az;
//            [dicFood removeObjectForKey:@"PRICE1"];
//            [dicFood setObject:a forKey:@"PRICE1"];
            [dicFood setObject:[NSString stringWithFormat:@"%.2f",a1] forKey:@"PRICE1"];
//            [dicFood setValue: forKey:  ];
            [aryDetailFood addObject:dicFood];
        }
        if (b1 != tcPrice) { //如果套餐明细的总价格与套餐不相等时
            NSDictionary *d = [aryDetailFood objectAtIndex:0];
            float b = tcPrice - b1;
            float indexPrice = [[d objectForKey:@"PRICE1"] floatValue]+b;
            [d setValue:[NSString stringWithFormat:@"%.2f",indexPrice] forKey:@"PRICE1"];
            [aryDetailFood replaceObjectAtIndex:0 withObject:d];
        }
    }else if ([tc isEqualToString:@"2"]){//方式二
        TCZZPirce = detailPrice;
        aryDetailFood = [[NSMutableArray alloc] initWithArray:[info objectForKey:@"foods"]];
    }else if ([tc isEqualToString:@"3"]){//方式三
        if (detailPrice > tcPrice){
            TCZZPirce = detailPrice;
            aryDetailFood = [[NSMutableArray alloc] init];
            TCZZPirce = tcPrice;
            float b1 = 0;
            //将套餐的价格平分给每一个子菜品
            for (NSDictionary *dicFood in [info objectForKey:@"foods"]) {
                float a1 = [[dicFood objectForKey:@"PRICE1"] floatValue]*tcPrice/detailPrice;
                NSString *a = [NSString stringWithFormat:@"%.2f",a1];
                float az = [a floatValue];
                b1 = b1 + az;
                [dicFood setValue:a forKey:@"PRICE1"];
                [aryDetailFood addObject:dicFood];
            }
            if (b1 != tcPrice) { //如果套餐明细的总价格与套餐不相等时
                NSDictionary *d = [aryDetailFood objectAtIndex:0];
                float b = tcPrice - b1;
                float indexPrice = [[d objectForKey:@"PRICE1"] floatValue]+b;
                [d setValue:[NSString stringWithFormat:@"%.2f",indexPrice] forKey:@"PRICE1"];
                [aryDetailFood replaceObjectAtIndex:0 withObject:d];
            }
        }else{
            TCZZPirce = tcPrice;
            aryDetailFood = [[NSMutableArray alloc] initWithArray:[info objectForKey:@"foods"]];
        }
    }else{//方式二  以上三种情况都不对的情况下用的方式二
        TCZZPirce = detailPrice;
    }
    return aryDetailFood;
}

//替换套餐总价格
-(NSMutableDictionary *)tcMonetyMode:(NSMutableDictionary *)info{
    NSString *tc = [info objectForKey:@"TCMONEYMODE"];
    //计算子菜品总价格
    float detailPrice = [self _tcAddDetailPrice:[info objectForKey:@"foods"]];//计算默认的详细菜品的总价格
    //    NSString *tcdetailPrice = [NSString stringWithFormat:@"%.1f",detailPrice];
    float tcPrice = [[info objectForKey:@"PRICE"] floatValue];
    float TCZZPirce;
    if ([tc isEqualToString:@"1"]) {  //方式一
        TCZZPirce = tcPrice;
    }else if ([tc isEqualToString:@"2"]){//方式二
        TCZZPirce = detailPrice;
        
    }else if ([tc isEqualToString:@"3"]){//方式三
        if (detailPrice > tcPrice){
            TCZZPirce = detailPrice;
        }else{
            TCZZPirce = tcPrice;
        }
    }else{//方式二  以上三种情况都不对的情况下用的方式二
        TCZZPirce = detailPrice;
    }
    NSMutableDictionary *foodInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
    //    foodInfo = info;
    NSString *p = [NSString stringWithFormat:@"%.1f",TCZZPirce];
    [foodInfo removeObjectForKey:@"PRICE"];
    [foodInfo setValue:p forKey:@"PRICE"];
    return foodInfo;
}

//计算默认的详细菜品的总价格
-(float)_tcAddDetailPrice:(NSArray *)aryDetailFood{
    float addDetailPrice = 0;
    for (NSDictionary *dic in aryDetailFood) {
        addDetailPrice = addDetailPrice + [[dic objectForKey:@"PRICE1"] floatValue];
    }
    return addDetailPrice;
}

#pragma mark - UISearchBarDelegate
//如果输入框里面的值改变开始重新搜索
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@",searchText);
    [[SearchCoreManager share] Search:searchText searchArray:nil nameMatch:searchByName phoneMatch:nil];
    NSNumber *localID = nil;
    NSMutableString *matchString = [NSMutableString string];
    NSMutableArray *matchPos = [NSMutableArray array];
     searchByResult = [NSMutableArray array];
    for (int i=0; i<[searchByName count]; i++) {
        //姓名匹配 获取对应匹配的拼音串 及高亮位置
        localID = [self.searchByName objectAtIndex:i];
        if ([self.searchBar.text length]) {
            [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
        }
        //按照筛选出得itcode查出菜品放入数组中
        NSString *itcode = [self.contactDic objectForKey:localID];
        for (NSMutableDictionary *dic in aryResult) {
            if ([[dic objectForKey:@"ITCODE"] isEqualToString:itcode]) {
                [searchByResult addObject:dic];
                break;
            }
        }
    }

    [searchByResult retain];
    
    [tvResult reloadData];
}


#pragma mark - SWKeyboard Delegate
- (void)keyboardTextChanged:(NSString *)inputText{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    self.aryResult = nil;
    int len = inputText.length;
    
    BOOL isPY = YES;
    NSMutableString *strPY = [NSMutableString string];
    for (int i=0;i<len;i++){
        NSRange range = NSMakeRange(i, 1);
        NSString *str = [inputText substringWithRange:range];
        if ([str isEqualToString:@"1"])
            isPY = NO;
        NSArray *arystr = [@",,ABC,DEF,GHI,JKL,MON,PQRS,TUV,WXYZ" componentsSeparatedByString:@","];
        NSString *strary = [arystr objectAtIndex:[str intValue]];
        if (strary.length>0)
            [strPY appendFormat:@"[%@]",strary];
    }
    
    NSLog(@"%@==>>%@",inputText,strPY);
    
    NSString *sqlStr = [NSString stringWithFormat:@"(ITCODE like '%@') or (DESCE GLOB '*%@*') or (INIT GLOB '*%@*')",inputText,strPY,strPY];
    self.aryResult = [dp getFoodList:sqlStr];
    [tvResult reloadData];
}
//#pragma mark - UISearchBarDelegate
//搜索框的代理
//- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
//{
//    BSDataProvider *dp = [BSDataProvider sharedInstance];
//    self.aryResult = nil;
//    NSString *sqlStr = [NSString stringWithFormat:@" (ITCODE like '%%%@%%') or (DESCE LIKE '%%%@%%') or (INIT LIKE '%%%@%%')",searchText,searchText,searchText];
//    self.aryResult = [dp getFoodList:sqlStr];
//    [tvResult reloadData];
//}


#pragma mark 类别的通知
//按照类别查询调用的通知方法
-(void)refreshTable:(NSNotification *)notification{
    NSString *typeID = (NSString *)notification.object;
    int tid = [typeID intValue];
   [self getTypeFoodList:tid];
}
//查询所有菜品
- (void )getTypeFoodList:(int *)typeID{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    //    self.aryResult = nil;
    int a = typeID;
    NSString *sqlStr;
    if (a == -1) {
        NSString *stree=[NSString string];
        stree=@"";
        for (NSDictionary *dict in classArray) {
            stree=[NSString stringWithFormat:@"%@%@",stree,[dict objectForKey:@"GRP"]];
            if (dict !=[classArray lastObject]) {
                stree=[NSString stringWithFormat:@"%@,",stree];
            }
        }
        
        sqlStr = [NSString stringWithFormat:@"CLASS in(%@)",stree];
        self.aryResult = [[dp getFoodList:sqlStr] retain];
    }else if(a == -2){
        sqlStr = @"ISTC=1";
    }else{
        //        sqlStr = [NSString stringWithFormat:@"class=%d",a];
        if ([self.searchBar.text length] <= 0) {
            for (NSDictionary *dict in self.aryResult) {
                if ([[dict objectForKey:@"CLASS"] intValue]==[[[classArray objectAtIndex:a] objectForKey:@"GRP"]intValue]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:a];
                    [tvResult scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    break;
                }
            }
            
        }
    }
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
    float offset = scrollView.contentOffset.y;
    if (offset < -30) {
        imgv.hidden = NO;
        boolSearch = YES;
        butSerachFood.frame = CGRectMake(0, 50, kLeftTableWidth-2, 30);
        imgv.frame = CGRectMake(0, 0, ScreenWidth, 50);
        tvResult.frame = CGRectMake(kLeftTableWidth, 50, ScreenWidth-kLeftTableWidth, self.view.frame.size.height-44);
        leftClass.frame = CGRectMake(0, 50+30, kLeftTableWidth-2, self.view.frame.size.height-44-30);
    }
}



//搜索框旁边的隐藏键盘按钮
- (void)updownClicked:(UIButton *)btn{
    [self.searchBar resignFirstResponder];
//    btn.selected = !btn.selected;
//    NSString *str = btn.selected?@"up":@"down";
//    if (btn.selected){
//        [self.searchBar resignFirstResponder];
//    }else{
//        [self.searchBar becomeFirstResponder];
//    }
//    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pad%@.png",str]] forState:UIControlStateNormal];
//    [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pad%@sel.png",str]] forState:UIControlStateHighlighted];
}


#pragma mark - SWInputView Delegate
- (void)keyboardPressed:(UIButton *)btn{
    if (btn.tag<10){
        NSMutableString *str = [NSMutableString string];
        [str appendString:self.tfInput.text];
        [str appendString:[NSString stringWithFormat:@"%d",btn.tag]];
        self.tfInput.text = str;
    }else if (11==btn.tag){
        if (self.tfInput.text.length>0)
            self.tfInput.text = [self.tfInput.text substringToIndex:self.tfInput.text.length-1];
    }
    [self keyboardTextChanged:self.tfInput.text];

}

#pragma mark - BSBookCellDelegate
/**
 *  Description 套餐换购
 *
 *  @param cell 当前的cell
 */
- (void)detailButAction:(BSBookCell *)cell{
    PackageViewController *pack = [[PackageViewController alloc] init];
    NSMutableDictionary *dic = cell.dicInfo;
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *mutAry = [dp getPackage:[dic objectForKey:@"ITCODE"]];
    [dic setValue:mutAry forKey:@"foods"];
    pack.packInfo = dic;
    pack.delegate = self;
    [self.navigationController pushViewController:pack animated:YES];
}

#pragma mark  点菜动画

//重写UIGestureRecognizerDelegate种的方法，解决手势和TableView的didSelect方法不能同时调用的问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
//    NSLog(@"%@", NSStringFromClass([touch.view class]));
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        CGPoint p = [touch locationInView:self.view];
        lx = p.x;
        ly = p.y;
        return NO;
    }
    return  YES;
}

//单击事件
-(void)tapClick:(UITapGestureRecognizer *)tap{
    CGPoint p = [tap locationInView:self.view];
    NSLog(@"%f===%f", p.y,p.x);
}

-(void)addToShow:(NSIndexPath *)indexPath cellx:(float)x1 celly:(float)y1{
    
    //声音
    BOOL sound = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sound"] boolValue];
    if (sound) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"addFood" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        SystemSoundID soundId;
        AudioServicesCreateSystemSoundID((CFURLRef)url, &soundId);
        AudioServicesPlaySystemSound(soundId);
    }
    
    //得到产品信息
    NSDictionary *dic = [aryResult objectAtIndex:indexPath.row];
    addPrice = [[dic valueForKey:@"PRICE"] intValue];
//    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"foodview"]];
//    imageView.contentMode=UIViewContentModeScaleToFill;
//    imageView.frame=CGRectMake(0, 0, 20, 20);
//    imageView.hidden=YES;
//    CGPoint point=CGPointMake(x1, y1-50);
//    imageView.center=point;
//    CALayer *layer=[[CALayer alloc]init];
//    layer.contents=imageView.layer.contents;
//    layer.frame=imageView.frame;
//    layer.opacity=1;
//    [self.view.layer addSublayer:layer];
//    CGPoint point1=imgMenu.center;
//    //动画 终点 都以sel.view为参考系
//    CGPoint endpoint=[tvResult convertPoint:point1 fromView:imgMenu];
//    UIBezierPath *path=[UIBezierPath bezierPath];
//    //动画起点
//    CGPoint startPoint=[tvResult convertPoint:point fromView:tvResult];
//    [path moveToPoint:startPoint];
//    //贝塞尔曲线中间点
//    float sx=startPoint.x;
//    float sy=startPoint.y;
//    float ex=endpoint.x;
//    float ey=endpoint.y;
//    float x=sx+(ex-sx)/3;
//    float y=sy+(ey-sy)*0.5-400;
//    CGPoint centerPoint=CGPointMake(x,y);
//    [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
//    
//    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
//    animation.path = path.CGPath;
//    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
//    animation.duration=0.8;
//    animation.delegate=self;
//    animation.autoreverses= NO;
//    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    [layer addAnimation:animation forKey:@"buy"];
    //加入购物车动画效果
    CALayer *transitionLayer = [[CALayer alloc] init];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    transitionLayer.opacity = 1.0;
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"foodview"]];
    //    transitionLayer.contents = (id)bt.titleLabel.layer.contents;
    transitionLayer.contents = (id)img.layer.contents;
    //    transitionLayer.frame = [[UIApplication sharedApplication].keyWindow convertRect:bt.titleLabel.bounds fromView:bt.titleLabel];
    transitionLayer.frame = CGRectMake(x1, y1, 20, 20);
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:transitionLayer];
    [CATransaction commit];
    [img release];
    
    //路径曲线
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:transitionLayer.position];
    CGPoint toPoint = CGPointMake(imgMenu.center.x, imgMenu.center.y+120);
    //    CGPoint toPoint = CGPointMake(0, 0);
    [movePath addQuadCurveToPoint:toPoint
                     controlPoint:CGPointMake(imgMenu.center.x,transitionLayer.position.y-120)];
    //    [movePath addQuadCurveToPoint:toPoint
    //                     controlPoint:CGPointMake(shopCarBt.center.x,0)];
    //关键帧
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = movePath.CGPath;
    positionAnimation.removedOnCompletion = YES;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime();
    group.duration = 0.7;
    group.animations = [NSArray arrayWithObjects:positionAnimation,nil];
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.autoreverses= NO;
    
    [transitionLayer addAnimation:group forKey:@"opacity"];
    [self performSelector:@selector(addShopFinished:) withObject:transitionLayer afterDelay:0.5f];
}

//计算总价格
-(float)addCount{
    allPrice = 0;
    NSMutableArray *aryMutOrder = [[BSDataProvider sharedInstance] orderedFood];
    for (NSDictionary *dicOrder in aryMutOrder) {
        float total = [[dicOrder objectForKey:@"total"] floatValue];
        float price = 0;
        if ([[dicOrder objectForKey:@"ISTC"] boolValue]) {
            price = [[dicOrder objectForKey:@"PRICE"] floatValue];
        }else if([[[dicOrder objectForKey:@"food"] objectForKey:@"UNITCUR"] intValue]==2){
            price = [[[dicOrder objectForKey:@"food"] objectForKey:@"PRICE"] floatValue]*[[[dicOrder objectForKey:@"food"] objectForKey:@"UNITCUR2"] floatValue];
        }else{
            price = [[[dicOrder objectForKey:@"food"] objectForKey:@"PRICE"] floatValue];
        }
        float add = price * total;
        allPrice = allPrice + add;
    }
    if (allPrice > 0) {
        butMenu.hidden = NO;
        allPriceLable.hidden = NO;
        NSString *allP = [NSString stringWithFormat:@"￥:%.2f ",allPrice];
        allPriceLable.text = allP;

        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            allPriceLable.frame = CGRectMake(ScreenWidth-25-allPriceLable.optimumSize.width-10, ScreenHeight-32-44-20+5, allPriceLable.optimumSize.width+10, 25);
            butMenu.frame = CGRectMake(ScreenWidth-25-allPriceLable.optimumSize.width-10-10, ScreenHeight-32-44-20, allPriceLable.optimumSize.width+10+12+10, 25);
        }else{
            allPriceLable.frame = CGRectMake(ScreenWidth-25-allPriceLable.optimumSize.width-10, ScreenHeight-32-44+5, allPriceLable.optimumSize.width+10, 25);
            butMenu.frame = CGRectMake(ScreenWidth-25-allPriceLable.optimumSize.width-10-10, ScreenHeight-32-44, allPriceLable.optimumSize.width+10+12+10, 25);
        }
        
    }else{
        butMenu.hidden = YES;
        allPriceLable.hidden = YES;
        allPriceLable.text = @"0";
    }
    return allPrice;
}

//加入购物车 步骤2
- (void)addShopFinished:(CALayer*)transitionLayer{
    
    [tvResult reloadData];
    
    allPrice = [self addCount];//计算总价格
   
    transitionLayer.opacity = 0;
        
    //价格上浮的动画效果
//    UILabel *addLabel = (UILabel*)[self.view viewWithTag:66];
    UILabel *addLabel = [[UILabel alloc] init];
    addLabel.frame = CGRectMake(150, 424, 79, 21);
    addLabel.opaque = NO;
    addLabel.alpha = 0;
    addLabel.clipsToBounds = YES;
    addLabel.textColor = [UIColor redColor];
    [addLabel setText:[NSString stringWithFormat:@"+%i",addPrice]];
    
    CALayer *transitionLayer1 = [[CALayer alloc] init];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    transitionLayer1.opacity = 1.0;
    transitionLayer1.contents = (id)addLabel.layer.contents;
    transitionLayer1.frame = [[UIApplication sharedApplication].keyWindow convertRect:addLabel.bounds fromView:addLabel];
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:transitionLayer1];
    [CATransaction commit];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(addLabel.frame.origin.x+30, addLabel.frame.origin.y+20)];
    positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(addLabel.frame.origin.x+30, addLabel.frame.origin.y)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0 * M_PI];
    rotateAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime();
    group.duration = 0.3;
    group.animations = [NSArray arrayWithObjects:positionAnimation,opacityAnimation,nil];
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.autoreverses= NO;
    [transitionLayer1 addAnimation:group forKey:@"opacity"];
    [self reloadTable];
    
}


@end
