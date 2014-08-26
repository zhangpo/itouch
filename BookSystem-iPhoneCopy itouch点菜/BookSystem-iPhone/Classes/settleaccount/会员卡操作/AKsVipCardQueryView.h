//
//  AKsVipCardQueryView.h
//  BookSystem
//
//  Created by sundaoran on 13-12-4.
//
//

#import <UIKit/UIKit.h>
#import "AKsPassWordView.h"
#import "AKsNetAccessClass.h"
#import "MBProgressHUD.h"


@protocol AKsVipCardQueryViewDelegate <NSObject>

-(void)VipCardCancle;

-(void)ClickPayButton:(NSMutableArray *)juanArray;
-(void)ClickDiancaiView;

-(void)controlClick:(UITextField *)cardTf;

@end


@interface AKsVipCardQueryView : UIView<UITableViewDataSource,UITableViewDelegate,AKsPassWordViewDelegate,AKsNetAccessClassDelegate,UITextFieldDelegate>
{
    id<AKsVipCardQueryViewDelegate>_delegate;
}

@property(nonatomic,retain) id<AKsVipCardQueryViewDelegate>delegate;

//-(void)makeTextFieldHide;

@end
