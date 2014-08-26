//
//  ZCLeftClassTable.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-3.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCLeftClassTable : UITableView<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *classArray;
    BOOL isPack;
}

@end
