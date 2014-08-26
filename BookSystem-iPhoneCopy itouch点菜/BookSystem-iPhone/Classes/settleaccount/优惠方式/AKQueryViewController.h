//
//  AKQueryViewController.h
//  BookSystem
//
//  Created by sundaoran on 13-11-23.
//
//

#import <UIKit/UIKit.h>
#import "AKMySegmentAndView.h"
#import "AKQueryAllOrders.h"
#import "AKShowPrivilegeView.h"
#import "AKsMoneyVIew.h"
#import "AKsBankView.h"
#import "AKsNetAccessClass.h"
#import "AKsCanDanListClass.h"
#import "AKsCheckAouthView.h"

@interface AKQueryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, AKMySegmentAndViewDelegate,UIAlertViewDelegate,AKQueryAllOrdersDelegate,AKShowPrivilegeViewDelegate,AKsMoneyVIewDelegate,aksBankViewDelegate,AKsNetAccessClassDelegate,AKsCheckAouthViewDelegate>
{
    
    UITableView *tvOrder;
    
}
@end

