//
//  favorableViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-13.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCfavorableViewController : UIViewController<UIScrollViewDelegate>{
    NSArray  *aryFeiLei;
    NSMutableArray *aryFeiLeiItem;
    UIScrollView *scvTables;
    int fenleiLine;
}

@end
