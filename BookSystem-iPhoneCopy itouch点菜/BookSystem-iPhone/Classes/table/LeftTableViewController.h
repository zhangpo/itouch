//
//  LeftTableViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-18.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface LeftTableViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *tabTable;
    CVLocalizationSetting *langSetting;
}

@end
