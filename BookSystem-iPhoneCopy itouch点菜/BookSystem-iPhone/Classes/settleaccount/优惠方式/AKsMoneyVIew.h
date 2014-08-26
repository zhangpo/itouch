//
//  AKsMoneyVIew.h
//  BookSystem
//
//  Created by sundaoran on 13-12-3.
//
//

//现金录入
#import "BSRotateView.h"

@protocol AKsMoneyVIewDelegate <NSObject>

-(void)sureMoney:(NSString *)money andName:(NSString *)name andTag:(int)btnTag;
-(void)cancleMoney;

@end

@interface AKsMoneyVIew : BSRotateView<UITextFieldDelegate>
{
     id<AKsMoneyVIewDelegate>_delegate;
}
@property(nonatomic,retain) id<AKsMoneyVIewDelegate>delegate;


- (id)initWithFrame:(CGRect)frame andName:(NSString *)name andTag:(int )btnTag;
@end
