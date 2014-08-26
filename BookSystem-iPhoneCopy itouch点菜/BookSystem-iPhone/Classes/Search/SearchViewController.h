//
//  SearchViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-18.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface SearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView *tvSerach;
    NSDictionary *dicInfo,*dicInfoResult;
    CVLocalizationSetting *langSetting;
}
@property (nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,retain) NSArray *aryInfo;

@end
