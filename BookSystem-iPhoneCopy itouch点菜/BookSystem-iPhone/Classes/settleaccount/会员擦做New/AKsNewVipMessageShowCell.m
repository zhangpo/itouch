//
//  AKsNewVipMessageShowCell.m
//  BookSystem
//
//  Created by sundaoran on 14-3-6.
//
//

#import "AKsNewVipMessageShowCell.h"

@implementation AKsNewVipMessageShowCell

@synthesize VipNum=_VipNum,jifenMoney=_jifenMoney,youxiaoTime=_youxiaoTime,chuZhiMoney=_chuZhiMoney,jihuoTime=_jihuoTime;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.contentView.backgroundColor=[UIColor whiteColor];
        _VipNum=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 192,40)];
        _VipNum.textAlignment=NSTextAlignmentCenter;
        _VipNum.layer.cornerRadius=5;
        _VipNum.backgroundColor=[UIColor clearColor];
        _VipNum.font=[UIFont systemFontOfSize:18];
        [self.contentView addSubview:_VipNum];
        
        _jihuoTime=[[UILabel alloc]initWithFrame:CGRectMake(142+50,0, 141,40)];
        _jihuoTime.textAlignment=NSTextAlignmentCenter;
        _jihuoTime.text=@"2014-12-12";
        _jihuoTime.layer.cornerRadius=5;
        _jihuoTime.backgroundColor=[UIColor clearColor];
        _jihuoTime.font=[UIFont systemFontOfSize:18];
        [self.contentView addSubview:_jihuoTime];
        
        _youxiaoTime=[[UILabel alloc]initWithFrame:CGRectMake(283+50,0, 141,40)];
        _youxiaoTime.textAlignment=NSTextAlignmentCenter;
        _youxiaoTime.text=@"2014-12-12";
        _youxiaoTime.layer.cornerRadius=5;
        _youxiaoTime.backgroundColor=[UIColor clearColor];
        _youxiaoTime.font=[UIFont systemFontOfSize:18];
        [self.contentView addSubview:_youxiaoTime];
        
        _chuZhiMoney=[[UILabel alloc]initWithFrame:CGRectMake(424+50,0, 141,40)];
        _chuZhiMoney.textAlignment=NSTextAlignmentCenter;
        _chuZhiMoney.text=@"9999.00";
        _chuZhiMoney.layer.cornerRadius=5;
        _chuZhiMoney.backgroundColor=[UIColor clearColor];
        _chuZhiMoney.font=[UIFont systemFontOfSize:18];
        [self.contentView addSubview:_chuZhiMoney];
        
        _jifenMoney=[[UILabel alloc]initWithFrame:CGRectMake(565+20,0, 141,40)];
        _jifenMoney.textAlignment=NSTextAlignmentCenter;
        _jifenMoney.text=@"9999.00";
        _jifenMoney.layer.cornerRadius=5;
        _jifenMoney.backgroundColor=[UIColor clearColor];
        _jifenMoney.font=[UIFont systemFontOfSize:18];
        [self.contentView addSubview:_jifenMoney];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
