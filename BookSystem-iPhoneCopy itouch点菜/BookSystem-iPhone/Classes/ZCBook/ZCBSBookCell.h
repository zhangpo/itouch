//
//  BSBookCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-4.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@class ZCBSBookCell;
@protocol ZCBSBookCellDelegate

- (void)detailButAction:(ZCBSBookCell *)cell;

@end

@interface ZCBSBookCell : UITableViewCell{
@private
    UIImageView     *_recommendImage;       //推荐头像
    RTLabel         *_foodLable;            //菜名
    RTLabel         *_priceLable;         //价格
    RTLabel         *_numberLable;          //编号
    RTLabel         *_amountLable;            //数量
    RTLabel         *_stateLable;            //数量的标签
    UIButton        *_detailBut;            //详情按钮
    UILabel         *_countLable;            //已点菜品数量
    UIImageView     *_imgYidian;            //已点标记
    UIViewController<ZCBSBookCellDelegate> *delegate;
}

@property (nonatomic,retain) NSMutableDictionary *dicInfo;
@property (nonatomic,assign) UIViewController<ZCBSBookCellDelegate> *delegate;

@end
