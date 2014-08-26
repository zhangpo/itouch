//
//  BSNewBookCell.h
//  BookSystem-iPhone
//
//  Created by chensen on 14-8-1.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@class BSNewBookCell;
@protocol BSBookCellDelegate

- (void)detailButAction:(BSNewBookCell *)cell;

@end

@interface BSNewBookCell : UITableViewCell{
@private
    UIImageView     *_recommendImage;       //推荐头像
    UILabel         *_foodLable;            //菜名
    RTLabel         *_priceLable;         //价格
    RTLabel         *_numberLable;          //编号
    RTLabel         *_amountLable;            //数量
    UILabel         *_countLable;            //已点菜品数量
    UIButton        *_detailBut;            //详情按钮
    UIImageView     *_imgYidian;            //已点标记
    id<BSBookCellDelegate> *delegate;
//    UIViewController<BSBookCellDelegate> *delegate;
}
@property(nonatomic,retain)NSMutableArray *selectArray;
@property (nonatomic,retain) NSMutableDictionary *dicInfo;
@property (nonatomic,assign) id<BSBookCellDelegate> *delegate;
@property (nonatomic,retain) NSArray *arySoldOut;

@end
