//
//  AKsPassWordView2.h
//  BookSystem
//
//  Created by sundaoran on 13-12-20.
//
//

#import "BSRotateView.h"

@protocol AKsPassWordView2Delegate <NSObject>

-(void)PassWord2Sure:(NSString *)passWord;
-(void)PassWord2Cancle;

@end
@interface AKsPassWordView2 : BSRotateView
{
     id<AKsPassWordView2Delegate>_delegate;
}
@property(nonatomic , retain) id<AKsPassWordView2Delegate> delegate;

@end
