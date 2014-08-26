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
#import "BSBookCell.h"
#import "PackageViewController.h"
#import "CVLocalizationSetting.h"
#import "LeftClassTableView.h"


@interface BSBookViewController : UIViewController<SWKeyboardDelegate,UITableViewDelegate,UITableViewDataSource,WRQueueDelegate,UIAlertViewDelegate,UISearchBarDelegate,SWInputViewDelegate,EGORefreshTableHeaderDelegate,BSBookCellDelegate,PackageViewControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>{
    UITableView *tvResult,*tvLeftClass;
    UIButton *btnOrdered,*btnBook;
    SWKeyboard *kbInput;
    
    NSMutableArray *aryResult,*aryAddition;
    NSArray *aryOrdered;
    NSString *strUnitKey,*strPriceKey;
    
    UISearchBar *searchBar;
    UIButton *btnKeyBoard;
//    UITextField *tfInput;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    UITapGestureRecognizer *_tapRecognizer;
    UIView *viewHeader;
    UIImageView *imgv;
    
    CVLocalizationSetting *langSetting;
    
    UIImageView *imgMenu;  //菜单图标
    UIButton *butMenu;     //菜单按钮
    int addPrice;
    float allPrice;
    
    LeftClassTableView *leftClass; //左视图
    UIButton           *butSerachFood;//搜索
    NSMutableArray *classArray;//菜品分类
    UIImageView *imgSeparator;//中间分割线
    
    NSMutableArray *searchByResult;
    NSMutableArray *searchClass;
    NSMutableArray *aryResultNew;
    RTLabel *allPriceLable;
    NSArray *arySoldOut;//沽清
    NSMutableDictionary *dicUnit2;//第二单位
    NSIndexPath *indexp2;
    
    float lx;
    float ly;
    
}
@property (nonatomic,retain) NSMutableArray *aryResult,*aryAddition;
@property (nonatomic,copy) NSString *strUnitKey,*strPriceKey;
@property (nonatomic,retain) NSMutableArray *searchByName;
@property (nonatomic,assign)UITextField *tfInput;
@property (nonatomic,retain) NSMutableDictionary *contactDic;
@property (nonatomic,retain) UISearchBar *searchBar;

- (void )getFoodList;

@end
