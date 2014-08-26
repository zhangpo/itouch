//
//  WaitTableView.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-27.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "BSRotateView.h"
#import "CVLocalizationSetting.h"

@protocol WaitTableViewDelegate

- (void)waitTableWithOptions:(NSDictionary *)info;

@end

@interface WaitTableView : BSRotateView<UITextFieldDelegate>{
    UIButton *btnConfirm,*btnCancel;
    UILabel *manLable,*womanLable,*phoneLable;
    UITextField *tfman,*tfwoman,*tfPhone;
    
    id<WaitTableViewDelegate> delegate;
    CVLocalizationSetting *langSetting;
}
@property (nonatomic,assign) id<WaitTableViewDelegate> delegate;

@end
