//
//  BSTableViewController.h
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCTableButton.h"
#import "ZCOpenTableView.h"
#import "ZCCancelTableView.h"
#import "ZCSwitchTableView.h"
#import "CVLocalizationSetting.h"



#define kOpenTag    700
#define kCancelTag  701
#define kFoodTag    702


@interface ZCTableViewController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate,UISearchBarDelegate,ZCOpenTableViewDelegate,ZCCancelTableViewDelegate,ZCSwitchTableViewDelegate,UIScrollViewDelegate> {
    UIScrollView *scvTables;

    
    NSArray *aryTables,*aryResvResult;
    
    int dSelectedIndex;
    
    NSDictionary *dicListTable;
    
    NSDictionary *checkTableInfo;
    CVLocalizationSetting *langSetting;
    
//    NSDictionary *openInfo;
    
    ZCOpenTableView *vOpen;
    ZCCancelTableView *vCancel;
    ZCSwitchTableView *vSwitch;
}
@property (nonatomic,retain) NSArray *aryTables,*aryResvResult;
@property (nonatomic,retain) NSDictionary *dicListTable;
@property (nonatomic, retain) NSDictionary *checkTableInfo;

- (void)showTables:(NSArray *)ary;
- (void)dismissViews;
@end
