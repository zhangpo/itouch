//
//  AKsPassWordView.h
//  BookSystem
//
//  Created by sundaoran on 13-12-4.
//
//

#import "BSRotateView.h"

@protocol AKsPassWordViewDelegate <NSObject>

-(void)PassWordSure:(NSString *)passWord;
-(void)PassWordCancle;

@end

@interface AKsPassWordView : BSRotateView<UITextFieldDelegate>
{
     id<AKsPassWordViewDelegate>_delegate;
}
@property(nonatomic , retain) id<AKsPassWordViewDelegate> delegate;

@end
