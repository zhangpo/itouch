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

@protocol AKsMoneyVIewDelegate <NSObject>

- (void)MoneyViewWithOptions:(NSDictionary *)info;

@end


@interface AKsMoneyVIew : BSRotateView<UITextFieldDelegate> {
    UIButton *btnConfirm,*btnCancel;
    UITextField *tfMoney;
    
    id<AKsMoneyVIewDelegate> delegate;
    CVLocalizationSetting *langSetting;
    
    NSMutableDictionary *dic;
}
@property (nonatomic,assign) id<AKsMoneyVIewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame dicMoney:(NSDictionary *)dicMoney;

@end
