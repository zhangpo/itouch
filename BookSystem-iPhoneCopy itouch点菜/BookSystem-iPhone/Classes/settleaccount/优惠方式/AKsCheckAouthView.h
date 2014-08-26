//
//  AKsCheckAouthView.h
//  BookSystem
//
//  Created by sundaoran on 14-1-14.
//
//

#import "BSRotateView.h"
#import "AKsSettlementClass.h"

@protocol AKsCheckAouthViewDelegate <NSObject>

-(void)cancleAKsCheckAouthView;
-(void)sureAKsCheckAouthView:(AKsSettlementClass *)Settlement andUserName:(NSString *)name andUserPass:(NSString *)pass;

@end

@interface AKsCheckAouthView : BSRotateView<UITextFieldDelegate>
{
    id<AKsCheckAouthViewDelegate>_delegate;
}

@property(nonatomic,retain) id<AKsCheckAouthViewDelegate>delegate;

-(id)initWithSettlment:(AKsSettlementClass *)Settlement;
- (id)initWithFrame:(CGRect)frame andSettlment:(AKsSettlementClass *)Settlement;

@end
