//
//  AKsJuanMessageListCell.m
//  BookSystem
//
//  Created by sundaoran on 13-12-13.
//
//

#import "AKsJuanMessageListCell.h"
#import "CardJuanClass.h"

@implementation AKsJuanMessageListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)greatViewOnCell:(CardJuanClass *)JuanList
{
    UILabel *YouName=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 155, 50)];
    YouName.textAlignment=NSTextAlignmentCenter;
    YouName.text=@"";
    YouName.backgroundColor=[UIColor clearColor];
    YouName.font=[UIFont systemFontOfSize:17];
    [self.contentView addSubview:YouName];
    

    UILabel *YouMoney=[[UILabel alloc]initWithFrame:CGRectMake(155,0, 155, 50)];
    YouMoney.textAlignment=NSTextAlignmentCenter;
    YouMoney.text=@"";
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
