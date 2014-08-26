//
//  AKsVipPayViewController.h
//  BookSystem
//
//  Created by sundaoran on 13-12-5.
//
//

#import <UIKit/UIKit.h>
#import "AKsNetAccessClass.h"
#import "PaymentSelect.h"
#import "AKsVipCaedChongZhiView.h"
#import "AKsPassWordView.h"
#import "AKsPassWordView2.h"
#import "AKMySegmentAndView.h"
#import "AKsYouHuiListClass.h"
#import "AKsCheckAouthView2.h"
//#import "Singleton.h"



@interface AKsVipPayViewController : UIViewController<AKsNetAccessClassDelegate,AKsVipCaedChongZhiViewDelegate,AKsPassWordViewDelegate,AKMySegmentAndViewDelegate,AKsPassWordView2Delegate,UITextFieldDelegate,AKsCheckAouthView2Delegate>

-(id)initWithArray:(NSMutableArray *)array;

@end
