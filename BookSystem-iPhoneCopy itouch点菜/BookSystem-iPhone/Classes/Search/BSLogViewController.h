//
//  BSLogViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface BSLogViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITabBarDelegate,UIAlertViewDelegate,UITextFieldDelegate>{
    UITableView *tvFood;
    int x;
    UILabel *lblAdditions;
    NSDictionary *dicInfo,*dicOrder,*dicInfoResult;
    CVLocalizationSetting *langSetting;
    UITextField *tfElide;
}
@property (nonatomic,retain) NSDictionary *dicInfo,*dicOrder;
@property (nonatomic,retain) NSArray *aryInfo;
@property (nonatomic,retain) NSMutableArray *arySelectedFood;

@end
