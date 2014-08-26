//
//  PackageViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@class ZCPackageViewController;
@protocol ZCPackageViewControllerDelegate

- (void)packOK:(ZCPackageViewController *)packView;

@end

@interface ZCPackageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView         *packageTable;
    NSMutableArray      *dicInfo;
//    NSMutableDictionary      *mutAry;
    
    UIViewController<ZCPackageViewControllerDelegate> *delegate;
    CVLocalizationSetting *langSetting;
}

@property(nonatomic,retain) NSMutableDictionary *packInfo;
@property(nonatomic,retain) NSMutableDictionary *mutAry;
@property (nonatomic,assign) UIViewController<ZCPackageViewControllerDelegate> *delegate;

@end
