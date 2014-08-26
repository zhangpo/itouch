//
//  AKsMoneyVIew.h
//  BookSystem
//
//  Created by sundaoran on 13-12-3.
//
//

//现金录入
#import "BSRotateView.h"
#import "CVLocalizationSetting.h"

@protocol ZCAKsMoneyVIewDelegate <NSObject>

- (void)MoneyViewWithOptions:(NSDictionary *)info;

@end


@interface ZCAKsMoneyVIew : BSRotateView<UITextFieldDelegate> {
    UIButton *btnConfirm,*btnCancel;
    UITextField *tfMoney;
    
    id<ZCAKsMoneyVIewDelegate> delegate;
    CVLocalizationSetting *langSetting;
    
    NSMutableDictionary *dic;
}
@property (nonatomic,assign) id<ZCAKsMoneyVIewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame dicMoney:(NSDictionary *)dicMoney;

@end
