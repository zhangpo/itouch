//
//  AKQueryAllOrders.h
//  BookSystem
//
//  Created by sundaoran on 13-12-2.
//
//

//选择账单号
#import "BSRotateView.h"
#import "AKsNetAccessClass.h"
#import "MBProgressHUD.h"

@protocol AKQueryAllOrdersDelegate <NSObject>

-(void)ordersSelectSure:(NSString *)orderNum;
-(void)ordersSelectCancle;

@end

@interface AKQueryAllOrders : BSRotateView<UITableViewDataSource,UITableViewDelegate,AKsNetAccessClassDelegate>
{
     id<AKQueryAllOrdersDelegate>_delegate;
}

@property(nonatomic,retain) id<AKQueryAllOrdersDelegate>deleagte;

-(void)setOrderArray:(NSArray *)array;


@end
