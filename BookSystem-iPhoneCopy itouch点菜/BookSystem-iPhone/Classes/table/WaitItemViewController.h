//
//  WaitItemViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-8.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"
#import "ChangeWaitTableView.h"

@interface WaitItemViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ChangeWaitTableViewDelegate>{
    CVLocalizationSetting *langSetting;
    UITableView *tvWaitItem;
    ChangeWaitTableView *changeView;
}

@property (nonatomic,assign)NSArray *aryWaitFood;
@property (nonatomic,assign)NSDictionary *dicInfo;

@end
