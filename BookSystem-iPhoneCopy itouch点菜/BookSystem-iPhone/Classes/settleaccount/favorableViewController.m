//
//  favorableViewController.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-13.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "favorableViewController.h"
#import "BSDataProvider.h"

@interface favorableViewController ()

@end

@implementation favorableViewController
@synthesize dicInfo,delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBGColor:nil];
    [self addNavBack];
//    [self addNavButtonWithTitle:[langSetting localizedString:@"VIP"] atPosition:SWNavItemPositionRight action:@selector(showVIP)];
    
    //查询分类
    aryFeiLei = [[[BSDataProvider sharedInstance] getCoupon_kind] retain];
    //动态显示 UISegmentedControl
    fenleiLine = [aryFeiLei count]/5+1;
    aryFeiLeiItem = [NSMutableArray array];
    NSMutableArray *ary = [NSMutableArray array];
    for (int i=0; i<[aryFeiLei count]; i++) {
        if (i%5 == 0 && i != 0) {
            [aryFeiLeiItem addObject:ary];
            ary = nil;
            ary = [NSMutableArray array];
            [ary addObject:[aryFeiLei objectAtIndex:i]];
        }else{
            [ary addObject:[aryFeiLei objectAtIndex:i]];
        }
    }
    //如果小于5的时候，循环中不会加人ary，在此加入一下
    if ([ary count] < 5) {
        [aryFeiLeiItem addObject:ary];
    }
    for (int i=0; i<fenleiLine; i++)
    {
        UISegmentedControl *segment=[[UISegmentedControl alloc]initWithFrame:CGRectMake(0, i*35, 320, 30)];
        segment.tag=i*5;
        segment.momentary = YES;
        for (int j=0; j<[[aryFeiLeiItem objectAtIndex:i] count]; j++)
        {
            NSString *str = [[[aryFeiLeiItem objectAtIndex:i] objectAtIndex:j] objectForKey:@"NAM"];
            [segment insertSegmentWithTitle:str atIndex:i*100+j animated:NO];
        }
        [segment addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
        segment.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:segment];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        scvTables = [[UIScrollView alloc] initWithFrame:CGRectMake(0, fenleiLine*35, ScreenWidth, ScreenHeight-44-20-fenleiLine*30)];
    }else{
        scvTables = [[UIScrollView alloc] initWithFrame:CGRectMake(0, fenleiLine*35, ScreenWidth, ScreenHeight-44-fenleiLine*30)];
    }
    scvTables.backgroundColor = [UIColor clearColor];
    scvTables.delegate = self;
    [self.view addSubview:scvTables];
    [scvTables release];
    
}


-(void)segmentClick:(UISegmentedControl *)segment
{
    int selectIndex=segment.selectedSegmentIndex+segment.tag+1;
    NSString *str = [NSString stringWithFormat:@"%d",selectIndex];
    NSArray *ary = [[BSDataProvider sharedInstance] getCoupon_main:str];
    aryCounp = nil;
    aryCounp = [[NSArray arrayWithArray:ary] retain];
    [self showKind:ary];
}


- (void)showKind:(NSArray *)ary{
    int count = [ary count];
    
    for (UIView *v in scvTables.subviews){
        if ([v isKindOfClass:[UIButton class]])
            [v removeFromSuperview];
    }
    
    for (int i=0;i<count;i++){
        int row = i/2;
        int column = i%2;
        NSDictionary *dic = [ary objectAtIndex:i];
        
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonBlue.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"TableButtonYellow.png"] forState:UIControlStateHighlighted];
        button.tag=i;
        [button setTitle:[dic objectForKey:@"NAM"] forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode=UILineBreakModeWordWrap;
        button.titleLabel.textAlignment=UITextAlignmentCenter;
        button.frame = CGRectMake(155*column+10, 60*row+10, 140, 50);
        button.tag = i;
        [button addTarget:self action:@selector(ButonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [scvTables addSubview:button];
        
        [scvTables setContentSize:CGSizeMake(320, 10+60*row+20+fenleiLine*35)];
        
    }
    
    
}

-(void)ButonClick:(UIButton *)but{
    NSDictionary *dic = [aryCounp objectAtIndex:but.tag];
    [SVProgressHUD showWithStatus:nil];
    [NSThread detachNewThreadSelector:@selector(userCounp:) toTarget:self withObject:dic];
}

//调用优惠接口
-(void)userCounp:(NSDictionary *)dicCounp{
    @autoreleasepool {
        NSDictionary *dic = [[BSDataProvider sharedInstance] userCounp:dicInfo CounpInfo:dicCounp];
        if ([[dic objectForKey:@"Result"] boolValue]) {
            NSMutableArray *ary = [dic objectForKey:@"Message"];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:[ary objectAtIndex:1] forKey:@"orderId"];
            [dic setValue:[ary objectAtIndex:2] forKey:@"counpId"];
            [dic setValue:[ary objectAtIndex:3] forKey:@"OPERATENAME"];
            [dic setValue:[ary objectAtIndex:4] forKey:@"counpCount"];
            [dic setValue:[ary objectAtIndex:5] forKey:@"money"];
            
            bs_dispatch_sync_on_main_thread(^{
                [delegate counp:dic];
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }else{
            bs_dispatch_sync_on_main_thread(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dic objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            });
        }
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
