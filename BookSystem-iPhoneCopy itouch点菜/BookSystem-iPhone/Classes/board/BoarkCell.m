//
//  BoarkCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-27.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "BoarkCell.h"

@implementation BoarkCell
@synthesize dicInfo;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 20)];
        lblName.numberOfLines = 3;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblName];
        
        lblShiji = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 50, 20)];
        lblShiji.backgroundColor = [UIColor clearColor];
        lblShiji.font = [UIFont boldSystemFontOfSize:13];
        lblShiji.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lblShiji];
        
        lblYuGu = [[UILabel alloc] initWithFrame:CGRectMake(190, 0, 50, 36)];
        lblYuGu.backgroundColor = [UIColor clearColor];
        lblYuGu.font = [UIFont boldSystemFontOfSize:13];
        lblYuGu.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lblYuGu];
        
        lblWanC = [[UILabel alloc] initWithFrame:CGRectMake(250, 10, 70, 20)];
        lblWanC.textAlignment = NSTextAlignmentLeft;
        lblWanC.backgroundColor = [UIColor clearColor];
        lblWanC.font = [UIFont boldSystemFontOfSize:13];
        lblWanC.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lblWanC];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDicInfo:(NSDictionary *)dic{
    if (dicInfo != dic) {
        dicInfo = dic;
    }
    [self showInfo:dic];
}

-(void)showInfo:(NSDictionary *)dic{
    lblName.text = [dic objectForKey:@"lookName"];
    lblShiji.text = [dic objectForKey:@"lookShi"];
    lblYuGu.text = [dic objectForKey:@"lookYu"];
    lblWanC.text = [dic objectForKey:@"lookwan"];
}

@end
