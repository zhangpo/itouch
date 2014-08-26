//
//  BSOrderedCell.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPPickerView.h"
#import "ZCAdditionsView.h"
#import "CVLocalizationSetting.h"

@class ZCBSOrderedCell;
@protocol BSOrderedCellDelegate

- (void)cellUpdated:(ZCBSOrderedCell *)cell;
- (void)Additions:(ZCBSOrderedCell *)cell;

@end

@interface ZCBSOrderedCell : UITableViewCell<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,ZCAdditionsViewDelegate,CPPickerViewDelegate,CPPickerViewDataSource,UIGestureRecognizerDelegate,UIAlertViewDelegate>{
    UIImageView *imgvPhoto;
    UILabel *lblName,*lblPriceUnit,*lblTotalPrice,*lblAdditions,*lblCount,*lblSelection,*lblAdditionPrice,*lblSelected;
    UIView *vPicker;
    ZCAdditionsView *vAdditions;
    
    NSMutableDictionary *dicInfo;
    UIViewController<BSOrderedCellDelegate> *delegate;
    float fCount;
    
    CPPickerView *defaultPickerView;
    CPPickerView *daysPickerView;
    
    CVLocalizationSetting *langSetting;
    BOOL bSelect;
}
@property (nonatomic,retain) NSMutableDictionary *dicInfo;
@property (nonatomic,assign) UIViewController<BSOrderedCellDelegate> *delegate;
@property BOOL bSelect;

@end
