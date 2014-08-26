//
//  BSPackageCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "BSPackageCell.h"
#import "BSAdditionsView.h"
#import "BSDataProvider.h"

@implementation BSPackageCell

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
    _flagImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _flagImage.backgroundColor = [UIColor clearColor];
    _flagImage.image = [UIImage imageNamed:@"qiehuan.png"];
    _flagImage.hidden = YES;
    [self.contentView addSubview:_flagImage];
    
    
    _foodLable = [[UILabel alloc] initWithFrame:CGRectZero];
    _foodLable.backgroundColor = [UIColor clearColor];
    _foodLable.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:_foodLable];
    
    
    _priceLable = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLable.backgroundColor = [UIColor clearColor];
    _priceLable.textColor = [UIColor redColor];
    _priceLable.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_priceLable];
 
}

//布局
- (void)layoutSubviews {
    [super layoutSubviews];
    _foodLable.frame = CGRectMake(10, 10, 150, 20);
    _priceLable.frame = CGRectMake(230, 10, 80, 20);
    _flagImage.frame = CGRectMake(ScreenWidth-30, 10, 25, 25);
    
}
//显示信息
- (void)showInfo:(NSDictionary *)info{
        _foodLable.text = [info objectForKey:@"PNAME"];
        NSString *strPrice = [NSString stringWithFormat:@"%@元/%@",[info objectForKey:@"PRICE1"],[info objectForKey:@"UNIT"]];
        _priceLable.text = strPrice;
        NSString *flag = (NSString *)[info objectForKey:@"TAG"];
        if ([flag isEqualToString:@"Y"]) {
            _flagImage.hidden = NO;
        }else{
            _flagImage.hidden = YES;
        }
}

-(void)setItemInfo:(NSMutableDictionary *)Info{
//    if (_itemInfo != Info) {
//        [_itemInfo release];
//        _itemInfo = [[NSMutableDictionary dictionaryWithDictionary:Info] retain];
//    }
    if (Info) {
        [self showInfo:Info];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
}


@end
