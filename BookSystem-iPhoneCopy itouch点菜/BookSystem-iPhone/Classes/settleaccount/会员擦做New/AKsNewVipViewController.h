//
//  AKsNewVipViewController.h
//  BookSystem
//
//  Created by sundaoran on 14-3-5.
//
//

#import <UIKit/UIKit.h>
#import "AKMySegmentAndView.h"
#import "AKsNetAccessClass.h"
#import "AKsNewVipMessageShowView.h"
#import "AKOrderRepastViewController.h"

@interface AKsNewVipViewController : UIViewController<AKMySegmentAndViewDelegate,UITextFieldDelegate,AKsNetAccessClassDelegate,UITableViewDataSource,UITableViewDelegate,AKsNewVipMessageShowViewDelegate>


@end
