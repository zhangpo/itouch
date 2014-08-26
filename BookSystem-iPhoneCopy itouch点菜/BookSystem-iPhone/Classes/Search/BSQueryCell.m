//
//  BSQueryCell.m
//  BookSystem
//
//  Created by Dream on 11-5-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSQueryCell.h"
#import "CVLocalizationSetting.h"


@implementation BSQueryCell
@synthesize dicInfo,bSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // Initialization code
        bSelected = NO;
        
        langSetting = [CVLocalizationSetting sharedInstance];
        
        imgSelect = [[UIImageView alloc] init];
        [imgSelect setImage:[UIImage imageNamed:@"select_no"]];
        imgSelect.backgroundColor = [UIColor clearColor];
        imgSelect.frame = CGRectMake(8, 9, 15, 15);
        [self.contentView addSubview:imgSelect];
        [imgSelect release];
        
        lblTuiCai = [[UILabel alloc] initWithFrame:CGRectMake(8, 17, 20, 20)];
        lblTuiCai.backgroundColor = [UIColor clearColor];
        lblTuiCai.font = [UIFont boldSystemFontOfSize:15];
        lblTuiCai.text = @"退";
        lblTuiCai.hidden = YES;
        [self.contentView addSubview:lblTuiCai];
        [lblTuiCai release];
        
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 225, 20)];
        lblName.numberOfLines = 3;
        lblName.backgroundColor = [UIColor clearColor];
        lblName.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblName];
        [lblName release];
        
        lblCount = [[UILabel alloc] initWithFrame:CGRectMake(35, 25, 70, 20)];
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblCount];
        [lblCount release];
        
        lblUnit = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 33, 36)];
        lblUnit.backgroundColor = [UIColor clearColor];
        lblUnit.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblUnit];
        [lblUnit release];
        
        lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(110, 25, 80, 20)];
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
        
        lblAddition = [[UILabel alloc] initWithFrame:CGRectMake(35, 48, 320, 15)];
        lblAddition.numberOfLines = 3;
        lblAddition.textColor = [UIColor redColor];
        lblAddition.backgroundColor = [UIColor clearColor];
        lblAddition.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblAddition];
        [lblAddition release];
        
        lblCuiCai = [[UILabel alloc] initWithFrame:CGRectMake(270, 5, 50, 20)];
        lblCuiCai.textAlignment = NSTextAlignmentCenter;
        lblCuiCai.backgroundColor = [UIColor clearColor];
        lblCuiCai.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblCuiCai];
        [lblCuiCai release];
        
        lblHuaCai = [[UILabel alloc] initWithFrame:CGRectMake(210, 5, 60, 20)];
        lblHuaCai.textAlignment = NSTextAlignmentCenter;
        lblHuaCai.backgroundColor = [UIColor clearColor];
        lblHuaCai.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblHuaCai];
        [lblHuaCai release];
        
        
        lblJiQi = [[UILabel alloc] initWithFrame:CGRectMake(8, 27, 15, 15)];
        lblJiQi.numberOfLines = 3;
        lblJiQi.textColor = [UIColor redColor];
        lblJiQi.backgroundColor = [UIColor clearColor];
        lblJiQi.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:lblJiQi];
        [lblJiQi release];
        
//        UILabel *lblline = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, 320, 1)];
//        lblline.backgroundColor = [UIColor colorWithRed:29.0f/255.0f green:55.0f/255.0f blue:82.0f/255.0f alpha:1.0];
//        [self.contentView addSubview:lblline];
//        [lblline release];
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
        price = [NSString stringWithFormat:@"%.2f/%@",[[dic objectForKey:@"priceDanJian"]floatValue],[dic objectForKey:@"unit"]];
    }else{
        price = [NSString stringWithFormat:@"%.2f",[[dic objectForKey:@"priceDanJian"]floatValue]];
    }
    lblPrice.text = price;
    lblTotalPrice.text = [NSString stringWithFormat:[langSetting localizedString:@"addCount"],[[dic objectForKey:@"price"] floatValue]];
//    lblUnit.text = [dic objectForKey:@"unit"];
//    lblAddition.hidden = YES;
    NSArray *strAdditions = [dic objectForKey:@"additions"];
    if ([strAdditions count]>0) {
    NSMutableString *str=[[NSMutableString alloc] init];
//    str=[NSMutableString stringWithFormat:@"%@",[langSetting localizedString:@"Additions:"]];
        [str appendString:[langSetting localizedString:@"Additions:"]];
//        str=[str stringByAppendingString:[langSetting localizedString:@"Additions:"]];
//        [str stringByAppendingString:];
        float fujiaprice=0.0;
    for (NSDictionary *dict in strAdditions){
        [str appendFormat:@"%@,",[dict objectForKey:@"fujianame"]];
        fujiaprice+=[[dict objectForKey:@"fujiaprice"] floatValue];
//        [str stringByAppendingFormat:@"%@",[dict objectForKey:@"fujianame"]];
    }
        
        [str appendFormat:@"附加项价格:%.2f",fujiaprice];
        lblAddition.text = str;
    }else{
        lblAddition.hidden = YES;
    }
    
    NSString *cui = [NSString stringWithFormat:@"催%@次",[dic objectForKey:@"rushCount"]];
    lblCuiCai.text = cui;
    NSString *h = @"0";
    if (![[dic objectForKey:@"pullCount"] isEqualToString:@""]) {
        h = [dic objectForKey:@"pullCount"];
    }
    NSString *elide = [NSString stringWithFormat:@"划:%@/%@",h,[dic objectForKey:@"pcount"]];
    lblHuaCai.text = elide;
    if ([[dic objectForKey:@"rushOrCall"] isEqualToString:@"1"]) {
        lblJiQi.text = @"即";
    }else{
        lblJiQi.text = @"叫";
    }
    
    
    if (![[dic objectForKey:@"IsQuit"] boolValue]) {
        self.contentView.backgroundColor = [UIColor grayColor];
        imgSelect.hidden = YES;
        lblTuiCai.hidden = NO;
        lblCuiCai.hidden = YES;
        lblHuaCai.hidden = YES;
    }else{
        imgSelect.hidden = NO;
        lblTuiCai.hidden = YES;
        lblCuiCai.hidden = NO;
        lblHuaCai.hidden = NO;
    }
}

#pragma mark bSelected's Getter & Setter
- (BOOL)bSelected{
    return bSelected;
}

- (void)setBSelected:(BOOL)bSelected_{
    bSelected = bSelected_;
    
    if (bSelected){
//        self.contentView.backgroundColor = [UIColor colorWithRed:0.0f green:155.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
//        for (UILabel *lbl in self.contentView.subviews){
//            if ([lbl isKindOfClass:[UILabel class]])
//                lbl.textColor = [UIColor whiteColor];
//        }
        [imgSelect setImage:[UIImage imageNamed:@"select_yes"]];
    }
    else{
//        self.contentView.backgroundColor = [UIColor clearColor];
//        for (UILabel *lbl in self.contentView.subviews){
//            if ([lbl isKindOfClass:[UILabel class]])
//                lbl.textColor = [UIColor blackColor];
//        }
        [imgSelect setImage:[UIImage imageNamed:@"select_no"]];
    }
}
@end
