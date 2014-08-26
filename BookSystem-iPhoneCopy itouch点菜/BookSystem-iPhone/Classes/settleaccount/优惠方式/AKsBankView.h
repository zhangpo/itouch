//
//  AKsBankView.h
//  BookSystem
//
//  Created by sundaoran on 13-12-3.
//
//

//银行卡支付录入
#import "BSRotateView.h"

@protocol aksBankViewDelegate <NSObject>

-(void)sureBank:(NSString *)money andName:(NSString *)name andTag:(int)btnTag andMonry:(NSString *)textmoney;
-(void)cancleBank;

@end
@interface AKsBankView : BSRotateView<UITextFieldDelegate>
{
     id<aksBankViewDelegate>_delegate;
}
@property(nonatomic,retain) id<aksBankViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame andName:(NSString *)name andTag:(int)btnTag andMonry:(NSString *)money;

@end
