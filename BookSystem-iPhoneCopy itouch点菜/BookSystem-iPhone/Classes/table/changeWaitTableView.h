//
//  changeWaitTableView.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-8.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "BSRotateView.h"
#import "CVLocalizationSetting.h"

@protocol ChangeWaitTableViewDelegate

- (void)ChangeWaitTableWithOptions:(NSDictionary *)info;

@end

@interface ChangeWaitTableView : BSRotateView<UITextFieldDelegate>{
    UIButton *btnConfirm,*btnCancel;
    UILabel *tableLable,*phoneLable;
    UITextField *tftable,*tfPhone;
    
    id<ChangeWaitTableViewDelegate> delegate;
    CVLocalizationSetting *langSetting;
}
@property (nonatomic,assign) id<ChangeWaitTableViewDelegate> delegate;

@end
