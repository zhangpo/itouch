//
//  BSLogViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"
#import "ZCChuckView.h"
#import "BSPrintQueryView.h"

@interface SettleAcount1ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITabBarDelegate,ZCChuckViewDelegate,PrintQueryViewDelegate>{
    UITableView *tvFood;
    
    NSDictionary *dicInfo,*dicOrder,*dicInfoResult;
    CVLocalizationSetting *langSetting;
    NSMutableArray *arySelectedFood;
    ZCChuckView *vChuck;
    BSPrintQueryView *vPrint;
}
@property (nonatomic,retain) NSDictionary *dicInfo,*dicOrder;

@end
