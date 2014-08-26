//
//  BSPackItemViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-11.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSPackItemViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView             *packageItemTable;
    NSMutableDictionary     *itemDic;
    NSMutableArray          *ary;
}

@property(nonatomic,retain)NSMutableArray *itemAry;
@end
