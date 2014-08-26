//
//  PackAdditionsCell.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-12.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "ZCPackAdditionsCell.h"
#import "CVLocalizationSetting.h"

@implementation ZCPackAdditionsCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _initView];
        langSetting = langSetting = [CVLocalizationSetting sharedInstance];
    }
    return self;
}

//初始化控件
- (void)_initView{ 
    _foodLable = [[UILabel alloc] initWithFrame:CGRectZero];
    _foodLable.backgroundColor = [UIColor clearColor];
    _foodLable.font = [UIFont systemFontOfSize:15.0];
    [self.contentView addSubview:_foodLable];
    
    
    _priceLable = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLable.backgroundColor = [UIColor clearColor];
    _priceLable.textColor = [UIColor redColor];
    _priceLable.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_priceLable];
    
    btnAdditions = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdditions.backgroundColor = [UIColor whiteColor];
    btnAdditions.clipsToBounds = YES;
    btnAdditions.layer.cornerRadius = 5;
    btnAdditions.layer.borderWidth = 1;
    btnAdditions.layer.borderColor = [UIColor colorWithWhite:.82 alpha:1].CGColor;
    [self.contentView addSubview:btnAdditions];
    [btnAdditions addTarget:self action:@selector(additionsClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _lblAdditions = [UILabel createLabelWithFrame:CGRectZero font:[UIFont systemFontOfSize:14]];
    _lblAdditions.textColor = [UIColor redColor];
    [btnAdditions addSubview:_lblAdditions];
    _lblAdditions.text = [langSetting localizedString:@"Additions:"];//附加项
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = btnAdditions.bounds;
    [btnAdditions.layer insertSublayer:gradientLayer atIndex:0];
    [gradientLayer release];
    
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:1].CGColor,(id)[UIColor colorWithWhite:.93f alpha:1].CGColor,nil];
    gradientLayer.startPoint = CGPointZero;
    gradientLayer.endPoint = CGPointMake(0.0, 1);
    
}

//布局
- (void)layoutSubviews {
    [super layoutSubviews];
    _foodLable.frame = CGRectMake(10, 10, 150, 20);
    _priceLable.frame = CGRectMake(ScreenWidth-70, 10, 70, 20);
    btnAdditions.frame = CGRectMake(12, 37, 170, 30);
    _lblAdditions.frame = CGRectMake(3, 0, btnAdditions.frame.size.width-6, btnAdditions.frame.size.height);
    
}
//显示信息
- (void)showInfo:(NSDictionary *)info{
    _foodLable.text = [info objectForKey:@"DES"];
    NSString *strPrice = [NSString stringWithFormat:@"%@/%@",[info objectForKey:@"PRICE"],[info objectForKey:@"UNIT"]];
    _priceLable.text = strPrice;
    
    NSArray *additions = [info objectForKey:@"addition"];
    NSMutableString *mutstr = [NSMutableString string];
    [mutstr appendString:[langSetting localizedString:@"Additions:"]];//附加项];
    for (int i=0;i<additions.count;i++){
        [mutstr appendString:0==i?[[additions objectAtIndex:i] objectForKey:@"DES"]:[NSString stringWithFormat:@",%@",[[additions objectAtIndex:i] objectForKey:@"DES"]]];
    }
    _lblAdditions.text = mutstr;
}

-(void)setItemInfo:(NSMutableDictionary *)Info{
    if (_itemInfo != Info) {
        [_itemInfo release];
        _itemInfo = [[NSMutableDictionary dictionaryWithDictionary:Info] retain];
    }
    if (Info) {
        [self showInfo:Info];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    
}

#pragma mark - actions
- (void)additionsClicked{
    ZCAdditionsView *v = [ZCAdditionsView additionsViewWithDelegate:self additions:[self.itemInfo objectForKey:@"addition"]];
    [v show];
}

#pragma mark - ZCAdditionsView Delegate
- (void)additionsSelected:(NSArray *)additions{
    if (additions.count>0)
        [self.itemInfo setObject:additions forKey:@"addition"];
    else
        [self.itemInfo removeObjectForKey:@"addition"];
    
    if ([delegate respondsToSelector:@selector(cellUpdated:)])
        [delegate cellUpdated:self];
}
@end
