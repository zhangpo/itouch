//
//  BSBookCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-4.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "BSBookCell.h"
#import "BSDataProvider.h"

@implementation BSBookCell
@synthesize delegate,arySoldOut;

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
    
    _foodLable = [[UILabel alloc] initWithFrame:CGRectZero];
    _foodLable.backgroundColor = [UIColor clearColor];
    _foodLable.numberOfLines = 3;
    _foodLable.font = [UIFont systemFontOfSize:13.0];
    [self.contentView addSubview:_foodLable];
    

    _priceLable = [[RTLabel alloc] initWithFrame:CGRectZero];
    _priceLable.backgroundColor = [UIColor clearColor];
    _priceLable.textColor = [UIColor redColor];
    _priceLable.font = [UIFont systemFontOfSize:11.0];
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

//显示信息
- (void)showInfo:(NSDictionary *)info{
    
    if ([[info objectForKey:@"ISTC"] isEqualToString:@"1"]) {
        _foodLable.frame = CGRectMake(10, 0, ScreenWidth-kLeftTableWidth-35, 30);
        _priceLable.frame = CGRectMake(10, 30, 80, 20);
//        _numberLable.frame = CGRectMake(150, 17, _numberLable.optimumSize.width, 20);
        _detailBut.frame = CGRectMake(ScreenWidth-kLeftTableWidth-50, 0, 50, 50);
        _imgYidian.frame = CGRectMake(10, 28, 20, 20);
        _countLable.frame = CGRectMake(0, 9, 20, 6);
        
        //显示已点菜品数量的判断
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSMutableArray *aryOrder = [db orderedFood];
        int countFood = 0;
        for (NSMutableDictionary *dicOrder in aryOrder) {
            if ([[dicOrder objectForKey:@"ISTC"] boolValue] && [[dicOrder objectForKey:@"ITCODE"] isEqualToString:[info objectForKey:@"ITCODE"]]) {
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
        
        //沽清判断
        for (NSString *sold in arySoldOut) {
            if ([[info objectForKey:@"ITCODE"] isEqualToString:sold]) {
                self.contentView.backgroundColor = [UIColor grayColor];
                break;
            }else{
                self.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
            }
        }
        
        _foodLable.text = [info objectForKey:@"DES"];
        NSString *count = [NSString stringWithFormat:@"%d",countFood];
        _countLable.text = count;
       
        _numberLable.text = [info objectForKey:@"ITCODE"];
        _amountLable.hidden = YES;
        _detailBut.hidden = NO;
        
        [self tcMonetyMode:info];//变价套餐

    }else{
        _foodLable.frame = CGRectMake(10, 0, ScreenWidth-kLeftTableWidth-5, 30);
//        _numberLable.frame = CGRectMake(20, 35, 100, 20);
//        _numberLable.textColor = [UIColor grayColor];
//        _priceLable.frame = CGRectMake(220, 35, 100, 20);
         _priceLable.frame = CGRectMake(10, 30, 80, 20);
        _imgYidian.frame = CGRectMake(10, 28, 20, 20);
        _countLable.frame = CGRectMake(0, 9, 20, 6);
        
        BSDataProvider *db = [BSDataProvider sharedInstance];
        NSMutableArray *aryOrder = [db orderedFood];
        int countFood = 0;
        for (NSMutableDictionary *dicOrder in aryOrder) {
            if (![[dicOrder objectForKey:@"ISTC"] boolValue] && [[[dicOrder objectForKey:@"food"] objectForKey:@"ITCODE"] isEqualToString:[info objectForKey:@"ITCODE"]]) {
                countFood = countFood + [[dicOrder objectForKey:@"total"] intValue];
            }
        }
        
        if (countFood > 0) {
            _imgYidian.hidden = NO;
            _countLable.hidden = NO;
            _priceLable.frame = CGRectMake(35, 32, 80, 20);
        }else{
            _countLable.hidden = YES;
            _imgYidian.hidden = YES;
        }
        
        //沽清判断
        for (NSString *sold in arySoldOut) {
            if ([[info objectForKey:@"ITCODE"] isEqualToString:sold]) {
                self.contentView.backgroundColor = [UIColor grayColor];
                NSLog(@"%@",[info objectForKey:@"ITCODE"]);
                break;
            }else{
                self.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:248.0/255.0 blue:215.0/255.0 alpha:1.0];
            }
        }
        
        NSString *count = [NSString stringWithFormat:@"%d",countFood];
        _countLable.text = count;
        _foodLable.text = [info objectForKey:@"DES"];
        NSString *priceStr = [NSString stringWithFormat:@"￥%@元/%@",[info objectForKey:@"PRICE"],[info objectForKey:@"UNIT"]];
        _priceLable.text = priceStr;
        _numberLable.text = [info objectForKey:@"ITCODE"];
//        _stateLable.text = @"可售数量:";
//        _amountLable.text = @"10";
        [_recommendImage setImage:[UIImage imageNamed:@"userImage.png"]];
        _amountLable.hidden = NO;
        _detailBut.hidden = YES;
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
//        _dicInfo = [NSMutableDictionary dictionary];
//        _dicInfo = [dic retain];
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
    [_countLable release];
    [super dealloc];
}


//变价套餐
-(void)tcMonetyMode:(NSDictionary *)info{
    NSString *tc = [info objectForKey:@"TCMONEYMODE"];
    
    //计算子菜品总价格
    
    NSString *priceStr;
    float detailPrice = [self _tcAddDetailPrice:[info objectForKey:@"ITCODE"]];//计算默认的详细菜品的总价格
    NSString *tcdetailPrice = [NSString stringWithFormat:@"%.1f",detailPrice];
    float tcPrice = [[info objectForKey:@"PRICE"] floatValue];
    if ([tc isEqualToString:@"1"]) {  //方式一
        priceStr = [NSString stringWithFormat:@"￥%@元/%@",[info objectForKey:@"PRICE"],[info objectForKey:@"UNIT"]];
    }else if ([tc isEqualToString:@"2"]){//方式二
        NSString *price = [NSString stringWithFormat:@"%.1f",detailPrice];
        priceStr = [NSString stringWithFormat:@"￥%@元/%@",price,[info objectForKey:@"UNIT"]];
    }else if ([tc isEqualToString:@"3"]){//方式三
        if (detailPrice == tcPrice) {
            priceStr = [NSString stringWithFormat:@"￥%@元/%@",[info objectForKey:@"PRICE"],[info objectForKey:@"UNIT"]];
        }else if (detailPrice > tcPrice){
            priceStr = [NSString stringWithFormat:@"￥%@元/%@",tcdetailPrice,[info objectForKey:@"UNIT"]];
        }else if (detailPrice < tcPrice){
            priceStr = [NSString stringWithFormat:@"￥%@元/%@",[info objectForKey:@"PRICE"],[info objectForKey:@"UNIT"]];
        }
    }else{//方式二  以上三种情况都不对的情况下用的方式二
        NSString *price = [NSString stringWithFormat:@"%.1f",detailPrice];
        priceStr = [NSString stringWithFormat:@"￥%@元/%@",price,[info objectForKey:@"UNIT"]];
    }
    _priceLable.text = priceStr;
}

//计算默认的详细菜品的总价格
-(float)_tcAddDetailPrice:(NSString *)itcode{
    float addPrice = 0;
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    NSMutableArray *mutAry = [dp getPackage:itcode];
    NSMutableArray *oldInfo = [NSMutableArray arrayWithArray:mutAry];
    NSMutableArray *a = [NSMutableArray array];
    for (NSMutableDictionary *mutD in oldInfo) {
        if ([[mutD objectForKey:@"defualtS"] isEqualToString:@"1"]) {
            NSString *tag = [mutD objectForKey:@"PRODUCTTC_ORDER"];
            [a addObject:tag];
        }
    }
    NSMutableArray *aryNew = [NSMutableArray array];
    for (NSMutableDictionary *mutD in oldInfo) {
        for (NSString *tag in a) {
            if ([[mutD objectForKey:@"PRODUCTTC_ORDER"] isEqualToString:tag]) {
                [mutD setObject:@"Y" forKey:@"TAG"];
            }
        }
        if ([[mutD objectForKey:@"defualtS"] isEqualToString:@"0"]) {
            [aryNew addObject:mutD];
        }
    }
    for (NSDictionary *dic in aryNew) {
        addPrice = addPrice + [[dic objectForKey:@"PRICE1"] floatValue];
    }
    return addPrice;
}
@end
