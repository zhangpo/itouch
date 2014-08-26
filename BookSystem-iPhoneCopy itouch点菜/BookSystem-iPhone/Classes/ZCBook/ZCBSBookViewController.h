//
//  BSSearchViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-25.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhiteRaccoon.h"
#import "SWKeyboard.h"
#import "EGORefreshTableHeaderView.h"
#import "ZCBSBookCell.h"
#import "ZCPackageViewController.h"
#import "CVLocalizationSetting.h"
#import "ZCLeftClassTable.h"

@interface ZCBSBookViewController : UIViewController<SWKeyboardDelegate,UITableViewDelegate,UITableViewDataSource,WRQueueDelegate,UIAlertViewDelegate,UISearchBarDelegate,SWInputViewDelegate,EGORefreshTableHeaderDelegate,ZCBSBookCellDelegate,ZCPackageViewControllerDelegate,UIGestureRecognizerDelegate>{
    UITableView *tvResult;
    UIButton *btnOrdered,*btnBook,*butSerachFood;
    SWKeyboard *kbInput;
    
    NSMutableArray *aryResult,*aryAddition,*classArray;
    NSArray *aryOrdered;
    NSString *strUnitKey,*strPriceKey;
    
    UISearchBar *searchBar;
    UITextField *tfInput;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    UITapGestureRecognizer *_tapRecognizer;
    UIView *viewHeader;
    UIImageView *imgv,*imgSeparator;
    
    ZCLeftClassTable *tvClass;
    
    CVLocalizationSetting *langSetting;
    UIMenuController *menuCtrl;
    int addPrice;
    float allPrice;
    UIImageView *imgMenu;  //菜单图标
    UIButton *butMenu;     //菜单按钮
    float lx;
    float ly;
    RTLabel *allPriceLable;
    UIButton *btnKeyBoard; //隐藏键盘
    
    BOOL isPack;
}
@property (nonatomic,retain) NSMutableArray *aryResult,*aryAddition,*arySerach,*aryPackage;
@property (nonatomic,copy) NSString *strUnitKey,*strPriceKey;

- (void )getFoodList;

@end
