//
//  PackAdditionsViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-12.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PackAdditionsCell.h"

@interface PackAdditionsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PackAdditionsCellDelegate>{
    UITableView         *packageTable;
    NSMutableArray      *dicInfo;
    NSMutableDictionary     *packMutDic;
}

@property(nonatomic,retain) NSMutableDictionary *packInfo;

@end
