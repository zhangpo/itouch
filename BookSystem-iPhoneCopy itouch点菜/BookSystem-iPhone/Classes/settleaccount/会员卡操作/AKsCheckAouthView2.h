//
//  AKsCheckAouthView2.h
//  BookSystem
//
//  Created by sundaoran on 14-1-14.
//
//

#import "BSRotateView.h"
#import "CardJuanClass.h"

@protocol AKsCheckAouthView2Delegate <NSObject>

-(void)cancleAKsCheckAouthView;
-(void)sureAKsCheckAouthView:(CardJuanClass *)cardMessage andUserName:(NSString *)name andUserPass:(NSString *)pass;

@end

@interface AKsCheckAouthView2 : BSRotateView<UITextFieldDelegate>
{
    id<AKsCheckAouthView2Delegate>_delegate;
}

@property(nonatomic,retain) id<AKsCheckAouthView2Delegate>delegate;


- (id)initWithFrame:(CGRect)frame andCardMessage:(CardJuanClass *)cardMessage;

@end
