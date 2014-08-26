//
//  WaitItemCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-8.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface WaitItemCell : UITableViewCell{
    UILabel *lblName,*lblCount,*lblUnit,*lblPrice,*lblTotalPrice;
    CVLocalizationSetting *langSetting;
}
@property (nonatomic,assign)NSDictionary *dicInfo;

@end
