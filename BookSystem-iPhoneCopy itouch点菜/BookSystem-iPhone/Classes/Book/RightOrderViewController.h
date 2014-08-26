//
//  RightOrderTableViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-24.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightOrderViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *tvOrder;
    NSArray *aryOrder;
}

@end
