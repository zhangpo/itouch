//
//  BSOrderedCell.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPPickerView.h"
#import "BSAdditionsView.h"
#import "CVLocalizationSetting.h"

@class BSOrderedCell;
@protocol BSOrderedCellDelegate

- (void)cellUpdated:(BSOrderedCell *)cell;
- (void)Additions:(BSOrderedCell *)cell;

@end

@interface BSOrderedCell : UITableViewCell<UIPickerViewDataSource,UIPickerViewDelegate,UISearchBarDelegate,BSAdditionsViewDelegate,CPPickerViewDelegate,CPPickerViewDataSource>{
    UIImageView *imgvPhoto;
    UILabel *lblName,*lblPriceUnit,*lblTotalPrice,*lblAdditions,*lblCount,*lblSelection;
    UIView *vPicker;
    BSAdditionsView *vAdditions;
    
    NSMutableDictionary *dicInfo;
    UIViewController<BSOrderedCellDelegate> *delegate;
    int fCount;
    
    CPPickerView *defaultPickerView;
    CPPickerView *daysPickerView;
    
    CVLocalizationSetting *langSetting;
}
@property (nonatomic,retain) NSMutableDictionary *dicInfo;
@property (nonatomic,assign) UIViewController<BSOrderedCellDelegate> *delegate;

@end
