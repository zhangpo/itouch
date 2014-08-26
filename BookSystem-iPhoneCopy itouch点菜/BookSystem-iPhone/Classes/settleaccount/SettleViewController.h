//
//  SettleViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-11.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"
#import "AKsMoneyVIew.h"
#import "BankCardView.h"
#import "favorableViewController.h"

@interface SettleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITabBarDelegate,AKsMoneyVIewDelegate,BankCardViewDelegate,favorableDelegate>{
    UITableView *tvSerach;
    NSDictionary *dicInfo,*dicInfoResult;
    CVLocalizationSetting *langSetting;
    AKsMoneyVIew           *_moneyView;
    UIPanGestureRecognizer          *_pan;
    
    UIView      *_viewmoney,*_viewBank;
    NSArray     *aryMoney,*aryBank;
    NSMutableArray  *aryFangShi;
    BankCardView     *bankCardView;
//    NSString *zhaoLing,*yingShou,*yingFu,*moLing,*order;
}
@property (nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,retain) NSArray *aryInfo;

@end
