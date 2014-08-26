//
//  BankCardView.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-13.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"
#import "BSRotateView.h"

@protocol ZCBankCardViewDelegate <NSObject>

- (void)BankCardWithOptions:(NSDictionary *)info;

@end

@interface ZCBankCardView : BSRotateView<UITextFieldDelegate> {
    UIButton *btnConfirm,*btnCancel;
    UITextField *tfMoney;
    
    id<ZCBankCardViewDelegate> delegate;
    CVLocalizationSetting *langSetting;
    
    NSMutableDictionary *dic;
}
@property (nonatomic,assign) id<ZCBankCardViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame dicMoney:(NSDictionary *)dicMoney;


@end
