//
//  BSPackageCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCAdditionsView.h"

@interface ZCPackageCell : UITableViewCell<ZCAdditionsViewDelegate>{
@private
    UILabel       *_foodLable;  //菜名
    UILabel       *_priceLable; //价格
    UIImageView   *_flagImage;  //标记是否可更换的图片
}

@property (nonatomic,retain) NSMutableDictionary *itemInfo;

@end
