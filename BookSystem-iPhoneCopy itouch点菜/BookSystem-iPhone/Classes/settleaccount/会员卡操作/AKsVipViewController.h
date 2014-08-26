//
//  AKsVipViewController.h
//  BookSystem
//
//  Created by sundaoran on 13-12-4.
//
//

#import <UIKit/UIKit.h>
#import "AKsVipCardQueryView.h"
#import "AKMySegmentAndView.h"
#import "AKsNetAccessClass.h"


@interface AKsVipViewController : UIViewController<AKsVipCardQueryViewDelegate,AKsNetAccessClassDelegate,UIAlertViewDelegate,AKMySegmentAndViewDelegate>

@end
