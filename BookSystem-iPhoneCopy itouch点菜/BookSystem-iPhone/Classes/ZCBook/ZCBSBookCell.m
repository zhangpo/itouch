//
//  BSBookCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-4.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "ZCBSBookCell.h"
#import "BSDataProvider.h"

@implementation ZCBSBookCell
@synthesize delegate;

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
    _recommendImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _recommendImage.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_recommendImage];
    

    _foodLable = [[RTLabel alloc] initWithFrame:CGRectZero];
    _foodLable.backgroundColor = [UIColor clearColor];
    _foodLable.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:_foodLable];
    

    _priceLable = [[RTLabel alloc] initWithFrame:CGRectZero];
    _priceLable.backgroundColor = [UIColor clearColor];
    _priceLable.textColor = [UIColor redColor];
    _priceLable.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_priceLable];
    
    _numberLable = [[RTLabel alloc] initWithFrame:CGRectZero];
    _numberLable.backgroundColor = [UIColor clearColor];
    _numberLable.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_numberLable];
    
    _amountLable = [[RTLabel alloc] initWithFrame:CGRectZero];
    _amountLable.backgroundColor = [UIColor clearColor];
    _amountLable.textColor = [UIColor grayColor];
    _amountLable.font = [UIFont systemFontOfSize:13.0];
    _amountLable.hidden = YES;
    [self.contentView addSubview:_amountLable];
    
    _stateLable = [[RTLabel alloc] initWithFrame:CGRectZero];
    _stateLable.backgroundColor = [UIColor clearColor];
    _stateLable.textColor = [UIColor grayColor];
    _stateLable.font = [UIFont systemFontOfSize:13.0];
    _stateLable.hidden = YES;
    [self.contentView addSubview:_stateLable];
    
    _detailBut = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"packNext.png"];
//    UIImage* stretchableImage = [image stretchableImageWithLeftCapWidth:0 topCapHeight:3];
    [_detailBut setBackgroundImage:img forState:UIControlStateNormal];
    [_detailBut addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
    _detailBut.hidden = YES;
    [self.contentView addSubview:_detailBut];
    
    
    _imgYidian = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"foodflag"]];
    _imgYidian.backgroundColor = [UIColor clearColor];
    _imgYidian.hidden = YES;
    [self.contentView addSubview:_imgYidian];
    
    _countLable = [[UILabel alloc] initWithFrame:CGRectZero];
    _countLable.backgroundColor = [UIColor clearColor];
    _countLable.textColor = [UIColor yellowColor];
    _countLable.font = [UIFont systemFontOfSize:8.0];
    _countLable.textAlignment = NSTextAlignmentCenter;
    _countLable.hidden = YES;
    [_imgYidian addSubview:_countLable];

}
//布局
- (void)layoutSubviews {
    [super layoutSubviews];
//    _foodLable.frame = CGRectMake(10, 10, 150, 20);
//    _priceLable.frame = CGRectMake(11, 35, 100, 20);
    
//    _recommendImage.frame = CGRectMake(_priceLable.optimumSize.width+15+10, 25, 10, 20); 
//    _numberLable.frame = CGRectMake(150, 10, _numberLable.optimumSize.width, 20);
//    _stateLable.frame = CGRectMake(225, 10, _stateLable.optimumSize.width, 20);
//    _amountLable.frame = CGRectMake(320-35, 10, _stateLable.optimumSize.width, 20);
//    _detailBut.frame = CGRectMake(ScreenWidth-50, 0, 50, 40);
   
}
//显示信息
- (void)showInfo:(NSDictionary *)info{
    
    if ([info objectForKey:@"PACKID"]) {
        _foodLable.frame = CGRectMake(10, 5, ScreenWidth-kLeftTableWidth-35, 30);
        _priceLable.frame = CGRectMake(10, 28, 80, 20);
        _detailBut.frame = CGRectMake(ScreenWidth-kLeftTableWidth-50, 0, 50, 50);
        _imgYidian.frame = CGRectMake(10, 28, 20, 20);
        _countLable.frame = CGRectMake(0, 9, 20, 6);
        
        //显示已点菜品数量的判断
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSMutableArray *aryOrder = [db orderedFood];
        int countFood = 0;
        for (NSMutableDictionary *dicOrder in aryOrder) {
            if ([[dicOrder objectForKey:@"isPack"] boolValue] && [[dicOrder objectForKey:@"PACKID"] isEqualToString:[info objectForKey:@"PACKID"]]) {
                countFood = countFood + [[dicOrder objectForKey:@"total"] intValue];
            }
        }
        if (countFood > 0) {
            _imgYidian.hidden = NO;
            _countLable.hidden = NO;
            _priceLable.frame = CGRectMake(35, 32, 80, 20);
        }else{
            _imgYidian.hidden = YES;
            _countLable.hidden = YES;
        }
        
        NSString *count = [NSString stringWithFormat:@"%d",countFood];
        _countLable.text = count;
        
        _foodLable.text = [info objectForKey:@"DES"];
        NSString *priceStr = [NSString stringWithFormat:@"￥%@元",[info objectForKey:@"PRICE"]];
        _priceLable.text = priceStr;
//        _numberLable.text = [info objectForKey:@"PACKID"];
        _numberLable.hidden = YES;
        _stateLable.hidden = YES;
        _amountLable.hidden = YES;
        _detailBut.hidden = NO;

    }else{
        _foodLable.text = [info objectForKey:@"DES"];
        NSString *priceStr = [NSString stringWithFormat:@"￥%@元/%@",[info objectForKey:@"PRICE"],[info objectForKey:@"UNIT"]];
        _priceLable.text = priceStr;
        [_recommendImage setImage:[UIImage imageNamed:@"userImage.png"]];
        _stateLable.hidden = YES;
        _amountLable.hidden = YES;
        _detailBut.hidden = YES;
        
        _foodLable.frame = CGRectMake(10, 5, ScreenWidth-kLeftTableWidth-5, 30);
        _priceLable.frame = CGRectMake(10, 28, 80, 20);
        _imgYidian.frame = CGRectMake(10, 28, 20, 20);
        _countLable.frame = CGRectMake(0, 9, 20, 6);
        
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSMutableArray *aryOrder = [db orderedFood];
        int countFood = 0;
        for (NSMutableDictionary *dicOrder in aryOrder) {
            if (![[dicOrder objectForKey:@"isPack"] boolValue] && [[[dicOrder objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:[info objectForKey:@"ITCODE"]]) {
                countFood = countFood + [[dicOrder objectForKey:@"total"] intValue];
            }
        }
        NSString *count = [NSString stringWithFormat:@"%d",countFood];
        _countLable.text = count;
        
        if (countFood > 0) {
            _imgYidian.hidden = NO;
            _countLable.hidden = NO;
            _priceLable.frame = CGRectMake(35, 32, 80, 20);
        }else{
            _countLable.hidden = YES;
            _imgYidian.hidden = YES;
        }
    }
}
#pragma mark -- Actions
//详情按钮
- (void)detailAction:(UIButton *)but{
    if ([delegate respondsToSelector:@selector(detailButAction:)]) {
        [delegate detailButAction:self];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDicInfo:(NSDictionary *)dic{
    
    if (_dicInfo!=dic){
        [_dicInfo release];
        _dicInfo = [[NSMutableDictionary dictionaryWithDictionary:dic] retain];
    }
    if (dic){
        [self showInfo:dic];
    }
}
- (void)dealloc
{
    [_recommendImage release];
    [_foodLable release];
    [_priceLable release];
    [_numberLable release];
    [_amountLable release];
    [_stateLable release];
    [super dealloc];
}

@end
