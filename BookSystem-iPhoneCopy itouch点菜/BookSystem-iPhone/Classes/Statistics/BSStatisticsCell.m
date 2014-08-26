//
//  BSStatisticsCell.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "BSStatisticsCell.h"
#import "BSDataProvider.h"
#import <QuartzCore/QuartzCore.h>

@implementation BSStatisticsCell
@synthesize dicInfo;

- (void)dealloc{
    self.dicInfo = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = CGRectMake(0, 0, 320, 28);
        [self.contentView.layer addSublayer:gradientLayer];
        [gradientLayer release];
        
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:1].CGColor,(id)[UIColor colorWithWhite:.93f alpha:1].CGColor,nil];
        gradientLayer.startPoint = CGPointZero;
        gradientLayer.endPoint = CGPointMake(0.0, 1);
        
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 28, 320, 104)];
        [imgv setImage:[UIImage imageNamed:@"chartbg.png"]];
        [self.contentView addSubview:imgv];
        [imgv release];
        
        lblTitle = [UILabel createLabelWithFrame:CGRectMake(10, 0, 150, 28) font:[UIFont boldSystemFontOfSize:14]];
        [self.contentView addSubview:lblTitle];
        
        lblStatus = [UILabel createLabelWithFrame:CGRectMake(0, 0, 320-5, 28) font:[UIFont systemFontOfSize:10] textColor:[UIColor colorWithWhite:.38 alpha:1]];
        lblStatus.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:lblStatus];
        
        imgvDone = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgvDone.backgroundColor = [UIColor colorWithRed:.15 green:.55 blue:.73 alpha:1];
        [self.contentView addSubview:imgvDone];
        [imgvDone release];
        
        imgvLeft = [[UIImageView alloc] initWithFrame:CGRectZero];
        imgvLeft.backgroundColor = [UIColor colorWithRed:.8 green:0 blue:.07 alpha:1];
        [self.contentView addSubview:imgvLeft];
        [imgvLeft release];
        
        lblDone = [UILabel createLabelWithFrame:CGRectZero font:[UIFont systemFontOfSize:10] textColor:[UIColor whiteColor]];
        lblDone.textAlignment = NSTextAlignmentCenter;
        [imgvDone addSubview:lblDone];
        
        lblLeft = [UILabel createLabelWithFrame:CGRectZero font:[UIFont systemFontOfSize:10] textColor:[UIColor whiteColor]];
        [imgvLeft addSubview:lblLeft];
    }
    return self;
}

- (void)showInfo:(NSDictionary *)dic{
    NSString *str = [dic objectForKey:@"data"];
    NSArray *ary = [str componentsSeparatedByString:@"^"];
    NSString *itcode = [ary objectAtIndex:0];
    NSString *plan = [ary objectAtIndex:1];
    NSString *curr = [ary objectAtIndex:2];
    
    NSDictionary *foodInfo = [[BSDataProvider sharedInstance] getFoodByCode:itcode];
    lblStatus.text = [NSString stringWithFormat:@"计划:%d 完成:%d 剩余:%d",[plan intValue],[curr intValue],[plan intValue]-[curr intValue]];
    lblTitle.text= [foodInfo objectForKey:@"DES"];
    
    float fcurr = [curr floatValue]/[plan floatValue];
    float fleft = 1-fcurr;
    
    imgvDone.frame = CGRectMake(20, 58, 274*fcurr, 26);
    imgvLeft.frame = CGRectMake(20+274*fcurr, 58, 274*fleft, 26);
    
    lblDone.frame = imgvDone.bounds;
    lblLeft.frame = imgvLeft.bounds;
    
    lblDone.text = [NSString stringWithFormat:@"%.0f%% ",fcurr*100];
    lblLeft.text = [NSString stringWithFormat:@" %.0f%%",fleft*100];
    
    if ([lblDone.text sizeWithFont:lblDone.font].width>lblDone.frame.size.width)
        lblDone.text = nil;
    
    if ([lblLeft.text sizeWithFont:lblLeft.font].width>lblLeft.frame.size.width)
        lblLeft.text = nil;
}

- (void)setDicInfo:(NSDictionary *)dic{
    if (dicInfo!=dic){
        [dicInfo release];
        dicInfo = [dic retain];
    }
    
    if (dic)
        [self showInfo:dic];
}

- (NSDictionary *)dicInfo{
    return dicInfo;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
