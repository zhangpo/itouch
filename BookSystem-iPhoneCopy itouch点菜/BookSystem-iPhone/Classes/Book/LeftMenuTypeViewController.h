//
//  LeftMenuTypeViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-2.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuTypeViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *menuType;
    
    NSMutableArray *classArray;
}

@end
