//
//  LeftMenuTypeViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-2.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCLeftMenuTypeViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *menuType;
    
    NSMutableArray *classArray;
}

@end
