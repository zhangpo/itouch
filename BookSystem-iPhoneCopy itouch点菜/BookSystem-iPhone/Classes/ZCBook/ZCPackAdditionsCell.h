//
//  PackAdditionsCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-12.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCAdditionsView.h"
#import "CVLocalizationSetting.h"

@class ZCPackAdditionsCell;
@protocol PackAdditionsCellDelegate

- (void)cellUpdated:(ZCPackAdditionsCell *)cell;

@end

@interface ZCPackAdditionsCell : UITableViewCell<ZCAdditionsViewDelegate>{
@private
    UILabel       *_foodLable;  //菜名
    UILabel       *_priceLable; //价格
    UILabel       *_lblAdditions;//附加项
    UIButton      *btnAdditions; //附加项button
    UIViewController<PackAdditionsCellDelegate> *delegate;
    CVLocalizationSetting *langSetting;
}

@property (nonatomic,retain) NSMutableDictionary *itemInfo;
@property (nonatomic,assign) UIViewController<PackAdditionsCellDelegate> *delegate;

@end
