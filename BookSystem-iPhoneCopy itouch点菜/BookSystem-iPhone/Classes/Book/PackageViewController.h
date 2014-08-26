//
//  PackageViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"
#import "BSNewBookCell.h"

@class PackageViewController;
@protocol PackageViewControllerDelegate

- (void)packOK:(PackageViewController *)packView;

@end

@interface PackageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView         *packageTable;
    NSMutableArray      *dicInfo;
    NSMutableArray      *selectArray;
//    NSMutableDictionary      *mutAry;
    
    UIViewController<PackageViewControllerDelegate> *delegate;
    CVLocalizationSetting *langSetting;
    float detailPrice;
}

@property(nonatomic,retain) NSMutableDictionary *packInfo,*packInfo2;
@property(nonatomic,retain) NSMutableDictionary *mutAry;
@property (nonatomic,assign) UIViewController<PackageViewControllerDelegate> *delegate;

@end
