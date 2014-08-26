//
//  AKsNewVipMessageShowCell.h
//  BookSystem
//
//  Created by sundaoran on 14-3-6.
//
//

#import <UIKit/UIKit.h>

@interface AKsNewVipMessageShowCell : UITableViewCell
{
    UILabel                 *_VipNum;
    UILabel                 *_jihuoTime;
    UILabel                 *_youxiaoTime;
    UILabel                 *_chuZhiMoney;
    UILabel                 *_jifenMoney;
}

@property(nonatomic,strong)UILabel *VipNum;
@property(nonatomic,strong)UILabel *jihuoTime;
@property(nonatomic,strong)UILabel *youxiaoTime;
@property(nonatomic,strong)UILabel *chuZhiMoney;
@property(nonatomic,strong)UILabel *jifenMoney;
@end
