//
//  CaiDanListCell.m
//  BookSystem
//
//  Created by sundaoran on 13-12-9.
//
//

#import "CaiDanListCell.h"
#import "AKsYouHuiListClass.h"

@implementation CaiDanListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        
    }
    return self;
}
-(void)setCellForArray:(AKsCanDanListClass *)caidan
{
    [self greatView:caidan];
}


-(void)greatView:(AKsCanDanListClass *)caidan
{
    UILabel *CaiCount=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 60, 45)];
    CaiCount.textAlignment=NSTextAlignmentCenter;
    CaiCount.text=[NSString stringWithFormat:@"%@",caidan.pcount];
    CaiCount.backgroundColor=[UIColor clearColor];
    CaiCount.font=[UIFont systemFontOfSize:17];
    [self.contentView addSubview:CaiCount];
    
    UILabel *CaiName=[[UILabel alloc]initWithFrame:CGRectMake(60,0, 190, 45)];
    CaiName.textAlignment=NSTextAlignmentCenter;
    if([caidan.weightflag isEqualToString:@"1"])
    {
        CaiName.text=[NSString stringWithFormat:@"%@",caidan.pcname];
    }
    else
    {
        CaiName.text=[NSString stringWithFormat:@"%@(赠送:%@)",caidan.pcname,caidan.weight];
    }
    CaiName.backgroundColor=[UIColor clearColor];
    CaiName.font=[UIFont systemFontOfSize:17];
    [self.contentView addSubview:CaiName];
    
    UILabel *CaiPrice=[[UILabel alloc]initWithFrame:CGRectMake(240,0, 70, 45)];
    CaiPrice.textAlignment=NSTextAlignmentCenter;
    CaiPrice.text=[NSString stringWithFormat:@"%.2f",[caidan.price floatValue]];
    CaiPrice.backgroundColor=[UIColor clearColor];
    CaiPrice.font=[UIFont systemFontOfSize:17];
    [self.contentView addSubview:CaiPrice];
    
    if(![caidan.fujianame isEqualToString:@""])
    {
        UILabel *FujiaName=[[UILabel alloc]initWithFrame:CGRectMake(30,45, 220, 30)];
        FujiaName.textAlignment=NSTextAlignmentLeft;
        FujiaName.text=[NSString stringWithFormat:@"附加项：%@",caidan.fujianame];
        FujiaName.backgroundColor=[UIColor clearColor];
        FujiaName.font=[UIFont systemFontOfSize:15];
        [self.contentView addSubview:FujiaName];
        
        UILabel *FujiaPrice=[[UILabel alloc]initWithFrame:CGRectMake(250,45, 60, 30)];
        FujiaPrice.textAlignment=NSTextAlignmentCenter;
        FujiaPrice.text=[NSString stringWithFormat:@"%.2f",[caidan.fujiaprice floatValue]];
        FujiaPrice.backgroundColor=[UIColor clearColor];
        FujiaPrice.font=[UIFont systemFontOfSize:15];
        [self.contentView addSubview:FujiaPrice ];
    }
    
    UILabel *line=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 310, 1)];
    line.backgroundColor=[UIColor blackColor];
    line.alpha=0.7;
    [self.contentView addSubview:line ];
    
}

-(void)setCellForAKsYouHuiList:(AKsYouHuiListClass *)list
{
    [self creatView:list];
}

-(void)creatView:(AKsYouHuiListClass*)list
{
    UILabel *YouName=[[UILabel alloc]initWithFrame:CGRectMake(0+20,0, 155-20, 50)];
    YouName.textAlignment=NSTextAlignmentLeft;
    YouName.text=[NSString stringWithFormat:@"%@",list.youName];
    YouName.backgroundColor=[UIColor clearColor];
    YouName.font=[UIFont systemFontOfSize:17];
    [self.contentView addSubview:YouName];
    
    
    
    UILabel *YouMoney=[[UILabel alloc]initWithFrame:CGRectMake(155-8,0, 155, 50)];
    YouMoney.textAlignment=NSTextAlignmentRight;
    YouMoney.text=[NSString stringWithFormat:@"-%.2f",[list.youMoney floatValue]];
    YouMoney.backgroundColor=[UIColor clearColor];
    YouMoney.font=[UIFont systemFontOfSize:17];
    [self.contentView addSubview:YouMoney];
    
    UILabel *line=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 310, 1)];
    line.backgroundColor=[UIColor blackColor];
    line.alpha=0.7;
    [self.contentView addSubview:line ];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
