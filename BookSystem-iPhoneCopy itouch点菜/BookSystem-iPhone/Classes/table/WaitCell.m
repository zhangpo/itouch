//
//  WaitCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-7.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "WaitCell.h"

@implementation WaitCell

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
    
    lblPhone = [[UILabel alloc] initWithFrame:CGRectZero];
    lblPhone.backgroundColor = [UIColor clearColor];
    lblPhone.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:lblPhone];
    
    
    lblCode = [[UILabel alloc] initWithFrame:CGRectZero];
    lblCode.backgroundColor = [UIColor clearColor];
    lblCode.textColor = [UIColor grayColor];
    lblCode.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:lblCode];
    
}

//布局
- (void)layoutSubviews {
    [super layoutSubviews];
    lblPhone.frame = CGRectMake(35, 5, 150, 20);
    lblCode.frame = CGRectMake(230, 5, 80, 20);
    
}
//显示信息
- (void)showInfo:(NSDictionary *)info{
    lblPhone.text = [info objectForKey:@"phone"];
    lblCode.text = [info objectForKey:@"misorderid"];
}

-(void)setDicInfo:(NSMutableDictionary *)Info{
    if (_dicInfo != Info) {
        [_dicInfo release];
        _dicInfo = [[NSMutableDictionary dictionaryWithDictionary:Info] retain];
    }
    if (Info) {
        [self showInfo:Info];
    }
}

@end
