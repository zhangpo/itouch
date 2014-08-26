//
//  BSOrderViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-3.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCBSOrderedCell.h"
#import "WhiteRaccoon.h"
#import "CVLocalizationSetting.h"

@interface ZCBSOrderViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,BSOrderedCellDelegate,UITabBarDelegate,UISearchBarDelegate,ZCAdditionsViewDelegate,WRRequestDelegate,UIAlertViewDelegate>{
    UITableView *tvList;
    UIView *vAdditions;
    UILabel *lblAdditions;
    NSMutableArray *aryCommonAdditions,*aryResult,*arySelectedAdditions,*aryTables,*arySelectFood;
    CVLocalizationSetting *langSetting;
    
}
@property (nonatomic,retain) NSMutableArray *aryCommonAdditions,*aryTables;
@property (nonatomic,retain) NSMutableArray *arySelectedFood;

@end
