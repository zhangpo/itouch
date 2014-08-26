//
//  SettleCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-11.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface ZCSettleCell : UITableViewCell{
    UILabel *lblName,*lblCount,*lblUnit,*lblPrice,*lblTotalPrice;
    
    
    NSDictionary *dicInfo,*dicFangShi;
    CVLocalizationSetting *langSetting;
    
}
@property BOOL bSelected;
@property (nonatomic,retain) NSDictionary *dicInfo;
@property (nonatomic,retain) NSDictionary *dicFangShi;

@end
