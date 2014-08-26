//
//  BSOrderFoodViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCOrderFoodViewController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITableView *tvResult;
    UISearchBar *searchBar;
    UIButton *btnOrdered,*btnBook;
    
    NSMutableArray *aryResult,*aryAddition;
    NSArray *aryOrdered;
    NSString *strUnitKey,*strPriceKey;

}
@property (nonatomic,retain) NSMutableArray *aryResult,*aryAddition;
@property (nonatomic,copy) NSString *strUnitKey,*strPriceKey;

@end
