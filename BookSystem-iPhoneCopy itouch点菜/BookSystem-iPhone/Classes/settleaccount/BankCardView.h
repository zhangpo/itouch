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

@protocol BankCardViewDelegate <NSObject>

- (void)BankCardWithOptions:(NSDictionary *)info;

@end

@interface BankCardView : BSRotateView<UITextFieldDelegate> {
    UIButton *btnConfirm,*btnCancel;
    UITextField *tfMoney;
    
    id<BankCardViewDelegate> delegate;
    CVLocalizationSetting *langSetting;
    
    NSMutableDictionary *dic;
}
@property (nonatomic,assign) id<BankCardViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame dicMoney:(NSDictionary *)dicMoney;


@end
