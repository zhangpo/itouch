//
//  SearchCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-18.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "ZCSettleCell.h"
#import "CVLocalizationSetting.h"

@implementation ZCSettleCell

@synthesize dicInfo,bSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // Initialization code
        bSelected = NO;
        
        langSetting = [CVLocalizationSetting sharedInstance];
        
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 170, 20)];
        lblName.numberOfLines = 3;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblName];
        [lblName release];
        
        lblCount = [[UILabel alloc] initWithFrame:CGRectMake(150, 5, 50, 20)];
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblCount];
        [lblCount release];
        
        
        lblTotalPrice = [[UILabel alloc] initWithFrame:CGRectMake(250, 5, 100, 20)];
        lblTotalPrice.textAlignment = NSTextAlignmentLeft;
        lblTotalPrice.backgroundColor = [UIColor clearColor];
        lblTotalPrice.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblTotalPrice];
        [lblTotalPrice release];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc
{
    //    self.dicInfo = nil;
    
    [super dealloc];
}

- (void)setDicInfo:(NSDictionary *)dic{
    if (dicInfo!=dic){
        [dicInfo release];
        dicInfo = [dic retain];
    }
    [self showInfo:dic];
}

- (void)setDicFangShi:(NSDictionary *)dic{
    if (dicFangShi!=dic){
        [dicFangShi release];
        dicFangShi = [dic retain];
    }
    [self showFangShi:dic];
}

- (void)showInfo:(NSDictionary *)dic{
    
    lblName.text = [dic objectForKey:@"name"];
//    NSString *count = [NSString stringWithFormat:[langSetting localizedString:@"Count1"],[dic objectForKey:@"pcount"]];
    lblCount.text = [dic objectForKey:@"total"];
//    lblTotalPrice.text = [NSString stringWithFormat:[langSetting localizedString:@"addCount"],[[dic objectForKey:@"price"] floatValue]];
    lblTotalPrice.text = [dic objectForKey:@"price"];
}

- (void)showFangShi:(NSDictionary *)dic{
    
    lblName.text = [dic objectForKey:@"OPERATENAME"];
    lblTotalPrice.text = [dic objectForKey:@"money"];
    lblCount.text = nil;
    if ([[dic objectForKey:@"OPERATENAME"] isEqualToString:@"优惠和服务费"]) {
        lblTotalPrice.frame = CGRectMake(200, 5, 120, 20);
    }else{
        lblTotalPrice.frame = CGRectMake(250, 5, 100, 20);
    }
}


@end
