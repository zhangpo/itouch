//
//  SearchCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-18.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "SearchCell.h"

@implementation SearchCell

@synthesize dicInfo,bSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // Initialization code
        bSelected = NO;
        
        langSetting = [CVLocalizationSetting sharedInstance];
        
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        lblName.numberOfLines = 3;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblName];
        [lblName release];
        
        lblCount = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 70, 20)];
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblCount];
        [lblCount release];
        
        lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 33, 36)];
        lblUnit.backgroundColor = [UIColor clearColor];
        lblUnit.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblUnit];
        [lblUnit release];
        
        lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 80, 20)];
        lblPrice.textAlignment = NSTextAlignmentLeft;
        lblPrice.backgroundColor = [UIColor clearColor];
        lblPrice.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblPrice];
        [lblPrice release];
        
        lblTotalPrice = [[UILabel alloc] initWithFrame:CGRectMake(200, 25, 120, 20)];
        lblTotalPrice.textAlignment = NSTextAlignmentLeft;
        lblTotalPrice.backgroundColor = [UIColor clearColor];
        lblTotalPrice.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblTotalPrice];
        [lblTotalPrice release];
        lbladditions=[[UILabel alloc] initWithFrame:CGRectMake(10, 50, 300, 30)];
        lbladditions.textAlignment = NSTextAlignmentLeft;
        lbladditions.backgroundColor = [UIColor clearColor];
        lbladditions.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lbladditions];
        
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

- (void)showInfo:(NSDictionary *)dic{
    
    if ([[dic objectForKey:@"ISTC"] boolValue] && ![[dic objectForKey:@"pcode"] isEqualToString:[dic objectForKey:@"tpcode"]]) {
        self.contentView.backgroundColor = [UIColor clearColor];
    }else if ([[dic objectForKey:@"ISTC"] boolValue] && [[dic objectForKey:@"pcode"] isEqualToString:[dic objectForKey:@"tpcode"]]) {
        self.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:215.0/255.0 alpha:1.0];
    }
    lblName.text = [dic objectForKey:@"pcname"];
    NSString *count = [NSString stringWithFormat:[langSetting localizedString:@"Count1"],[dic objectForKey:@"pcount"]];
    lblCount.text = count;
    NSString *price = nil;
    if (![[dic objectForKey:@"unit"] isEqualToString:@""]) {
        price = [NSString stringWithFormat:@"%.2f/%@",[[dic objectForKey:@"price"]floatValue]/[[dic objectForKey:@"pcount"] floatValue],[dic objectForKey:@"unit"]];
    }else{
        price = [NSString stringWithFormat:@"%.2f",[[dic objectForKey:@"price"]floatValue]/[[dic objectForKey:@"pcount"] floatValue]];
    }
    lblPrice.text = price;
    lblTotalPrice.text = [NSString stringWithFormat:[langSetting localizedString:@"addCount"],[[dic objectForKey:@"price"] floatValue]];
    if ([[dic objectForKey:@"additions"] length]>2) {
        lbladditions.text=[NSString stringWithFormat:@"附加项:%@ 附加项价格:%@",[dic objectForKey:@"additions"],[dic objectForKey:@"fujiaprice"]];
    }

}


@end
