//
//  BSStatisticsViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-25.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSStatisticsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *tvStatistics;
    
    NSArray *aryList;
}
@property (nonatomic,retain) NSArray *aryList;

@end
