//
//  BSBookCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-4.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@class BSBookCell;
@protocol BSBookCellDelegate

- (void)detailButAction:(BSBookCell *)cell;

@end

@interface BSBookCell : UITableViewCell{
@private
    UIImageView     *_recommendImage;       //推荐头像
    UILabel         *_foodLable;            //菜名
    RTLabel         *_priceLable;         //价格
    RTLabel         *_numberLable;          //编号
    RTLabel         *_amountLable;            //数量
    UILabel         *_countLable;            //已点菜品数量
    UIButton        *_detailBut;            //详情按钮
    UIImageView     *_imgYidian;            //已点标记
    UIViewController<BSBookCellDelegate> *delegate;
}

@property (nonatomic,retain) NSMutableDictionary *dicInfo;
@property (nonatomic,assign) UIViewController<BSBookCellDelegate> *delegate;
@property (nonatomic,retain) NSArray *arySoldOut;

@end
