//
//  RightOrderCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-24.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "RightOrderCell.h"
#import "BSDataProvider.h"

@implementation RightOrderCell
@synthesize  dicInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        lblName = [[UILabel alloc] init];
        lblName.frame = CGRectMake(15, 0, 90, 30);
        lblName.font = [UIFont systemFontOfSize:10.0f];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.numberOfLines = 3;
        [self.contentView addSubview:lblName];
        [lblName release];
        
        lblTotal = [[UILabel alloc] init];
        lblTotal.frame = CGRectMake(115, 0, 30, 30);
        lblTotal.font = [UIFont systemFontOfSize:10.0f];
        lblTotal.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:lblTotal];
        [lblTotal release];
    }
    return self;
}

-(void)setDicInfo:(NSDictionary *)dic{
    if (dicInfo!=dic) {
        [dicInfo release];
        dicInfo = [[NSDictionary dictionaryWithDictionary:dic] retain];
    }
    if (dic) {
        [self showInfo:dicInfo];
    }
    
}

-(void)showInfo:(NSDictionary *)dic{
    if ([[dic objectForKey:@"ISTC"] boolValue]) {
        lblName.text = [dic objectForKey:@"DES"];
        //显示已点菜品数量的判断
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSMutableArray *aryOrder = [db orderedFood];
        int countFood = 0;
        for (NSMutableDictionary *dicOrder in aryOrder) {
            if ([[dicOrder objectForKey:@"ISTC"] boolValue] && [[dicOrder objectForKey:@"ITCODE"] isEqualToString:[dic objectForKey:@"ITCODE"]]) {
                countFood = countFood + [[dicOrder objectForKey:@"total"] intValue];
            }
        }
        if (countFood > 0) {
            lblTotal.text = [NSString stringWithFormat:@"%d",countFood];
        }
    }else{
        lblName.text = [[dic objectForKey:@"food"] objectForKey:@"DES"];
        //显示已点菜品数量的判断
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSMutableArray *aryOrder = [db orderedFood];
        int countFood = 0;
        for (NSMutableDictionary *dicOrder in aryOrder) {
            if (![[dicOrder objectForKey:@"ISTC"] boolValue] && [[[dicOrder objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:[[dic objectForKey:@"food"] objectForKey:@"ITCODE"]]) {
                countFood = countFood + [[dicOrder objectForKey:@"total"] intValue];
            }
        }
        if (countFood > 0) {
            lblTotal.text = [NSString stringWithFormat:@"%d",countFood];
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
