//
//  BSOrderViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-3.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSOrderedCell.h"
#import "CVLocalizationSetting.h"
#import "AdditionsView.h"

@interface BSOrderViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,BSOrderedCellDelegate,UITabBarDelegate,UISearchBarDelegate,AdditionsViewDelegate,UIAlertViewDelegate>{
    UITableView *tvList;
    UIView *vAdditions;
    
    NSMutableArray *aryCommonAdditions,*aryResult,*arySelectedAdditions,*aryTables;
    CVLocalizationSetting *langSetting;
    UILabel *lblAdditions;
}
@property (nonatomic,retain) NSMutableArray *aryCommonAdditions,*aryTables;

@end
