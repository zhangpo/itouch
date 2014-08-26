//
//  BSSwitchTableView.h
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"
#import "CVLocalizationSetting.h"

@protocol ZCSwitchTableViewDelegate

- (void)switchTableWithOptions:(NSDictionary *)info;

@end


@interface ZCSwitchTableView : BSRotateView<UITextFieldDelegate> {
    UIButton *btnConfirm,*btnCancel;
    UILabel *lblOldTable,*lblNewTable;
    UITextField *tfOldTable,*tfNewTable;
    CVLocalizationSetting *langSetting;
    id<ZCSwitchTableViewDelegate> delegate;
}
@property (nonatomic,assign) id<ZCSwitchTableViewDelegate> delegate;
@property (nonatomic,assign) UITextField *tfOldTable,*tfNewTable;

@end
