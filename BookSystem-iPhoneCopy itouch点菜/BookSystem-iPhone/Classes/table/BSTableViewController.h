//
//  BSTableViewController.h
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSTableButton.h"
#import "BSOpenTableView.h"
#import "BSCancelTableView.h"
#import "BSSwitchTableView.h"
#import "BSCombineTableView.h"
#import "CVLocalizationSetting.h"
#import "WaitViewController.h"

#define kOpenTag    700
#define kCancelTag  701
#define kFoodTag    702


@interface BSTableViewController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate,UISearchBarDelegate,OpenTableViewDelegate,CancelTableViewDelegate,SwitchTableViewDelegate,combineTableDelegate,WaitViewControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate> {
    UIScrollView *scvTables;

    
    NSArray *aryTables,*aryResvResult;
    
    int dSelectedIndex;
    
    NSDictionary *dicListTable;
    
    NSDictionary *checkTableInfo;
    
//    NSDictionary *openInfo;
    
    BSOpenTableView *vOpen;
    BSCancelTableView *vCancel;
    BSSwitchTableView *vSwitch;
    CVLocalizationSetting *langSetting;
    BSCombineTableView *vCombine;
    UIImageView *imgv;
    UISearchBar *searchBar;
    NSMutableArray *searchByResult;
    NSMutableArray *searchClass;
    NSMutableArray *aryResultNew;
    UIViewController *tableMenu;
    
}
@property (nonatomic,assign) NSArray *aryTables,*aryResvResult,*aryTableResult;
@property (nonatomic,retain) NSDictionary *dicListTable;
@property (nonatomic, retain) NSDictionary *checkTableInfo;
@property (nonatomic,retain) NSMutableArray *searchByName;
@property (nonatomic,retain) NSMutableDictionary *contactDic;

- (void)showTables:(NSArray *)ary;
- (void)dismissViews;
@end
