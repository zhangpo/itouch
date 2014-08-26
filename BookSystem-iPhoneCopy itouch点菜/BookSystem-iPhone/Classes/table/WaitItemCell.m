//
//  WaitItemCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-8.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "WaitItemCell.h"
#import "CVLocalizationSetting.h"

@implementation WaitItemCell
@synthesize dicInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _initView];
    }
    return self;
}
//初始化控件
- (void)_initView{
    
    langSetting = [CVLocalizationSetting sharedInstance];
    
    lblName = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 225, 20)];
    lblName.numberOfLines = 3;
    lblName.backgroundColor = [UIColor clearColor];
    lblName.font = [UIFont boldSystemFontOfSize:13];
    [self.contentView addSubview:lblName];
    [lblName release];
    
    lblCount = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 70, 20)];
    lblCount.backgroundColor = [UIColor clearColor];
    lblCount.font = [UIFont boldSystemFontOfSize:13];
    [self.contentView addSubview:lblCount];
    [lblCount release];
    
    lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 33, 36)];
    lblUnit.backgroundColor = [UIColor clearColor];
    lblUnit.font = [UIFont boldSystemFontOfSize:13];
    [self.contentView addSubview:lblUnit];
    [lblUnit release];
    
    lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 80, 20)];
    lblPrice.textAlignment = NSTextAlignmentCenter;
    lblPrice.backgroundColor = [UIColor clearColor];
    lblPrice.font = [UIFont boldSystemFontOfSize:13];
    [self.contentView addSubview:lblPrice];
    [lblPrice release];
    
    lblTotalPrice = [[UILabel alloc] initWithFrame:CGRectMake(200, 25, 100, 20)];
    lblTotalPrice.textAlignment = NSTextAlignmentLeft;
    lblTotalPrice.backgroundColor = [UIColor clearColor];
    lblTotalPrice.font = [UIFont boldSystemFontOfSize:13];
    [self.contentView addSubview:lblTotalPrice];
    [lblTotalPrice release];
    
}

//显示信息
- (void)showInfo:(NSDictionary *)dic{
    if ([[dic objectForKey:@"ISTC"] boolValue] && ![[dic objectForKey:@"pcode"] isEqualToString:[dic objectForKey:@"tpcode"]]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }else if ([[dic objectForKey:@"ISTC"] boolValue] && [[dic objectForKey:@"pcode"] isEqualToString:[dic objectForKey:@"tpcode"]]) {
        self.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:215.0/255.0 alpha:1.0];
    }else{
        self.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
    }
    lblName.text = [dic objectForKey:@"pcname"];
    NSString *count = [NSString stringWithFormat:[langSetting localizedString:@"Count1"],[dic objectForKey:@"pcount"]];
    lblCount.text = count;
    NSString *price = nil;
    if (![[dic objectForKey:@"unit"] isEqualToString:@""]) {
        price = [NSString stringWithFormat:@"%.2f/%@",[[dic objectForKey:@"price"]floatValue],[dic objectForKey:@"unit"]];
    }else{
        price = [NSString stringWithFormat:@"%.2f",[[dic objectForKey:@"price"]floatValue]];
    }
    lblPrice.text = price;
    lblTotalPrice.text = [NSString stringWithFormat:[langSetting localizedString:@"addCount"],[[dic objectForKey:@"pcount"] floatValue]*[[dic objectForKey:@"price"] floatValue]];
}

-(void)setDicInfo:(NSMutableDictionary *)Info{
    if (dicInfo != Info) {
        [dicInfo release];
        dicInfo = [[NSMutableDictionary dictionaryWithDictionary:Info] retain];
    }
    if (Info) {
        [self showInfo:Info];
    }
}
@end
