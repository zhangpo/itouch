//
//  LeftClassTableView.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-14.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftClassTableView : UITableView<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *classArray;
}

@end
