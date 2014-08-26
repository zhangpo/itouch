//
//  BoardViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-27.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface BoardViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView *tvBoark;
    CVLocalizationSetting *langSetting;
    NSArray *aryResult;
    NSDictionary *dicResult;
}

@end
