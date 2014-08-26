//
//  SearchCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-18.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface SearchCell : UITableViewCell{
    UILabel *lblName,*lblCount,*lblUnit,*lblPrice,*lblTotalPrice,*lbladditions;

    
    NSDictionary *dicInfo;
    CVLocalizationSetting *langSetting;

}
@property BOOL bSelected;
@property (nonatomic,retain) NSDictionary *dicInfo;

@end
