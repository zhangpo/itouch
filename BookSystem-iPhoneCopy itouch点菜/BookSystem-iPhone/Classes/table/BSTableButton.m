//
//  BSTableButtion.m
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSTableButton.h"


@implementation BSTableButton
@synthesize delegate;


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}



- (BSTableType)tableType{
    return tableType;
}

-(void)_initView{
    langSetting = [CVLocalizationSetting sharedInstance];
    imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(10, 20, 60, 60);
    [self addSubview:imageView];
    
    self.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:0]; //设置矩形四个圆角半径
    [self.layer setBorderWidth:0]; //边框宽度
//    [self.layer setBorderColor:colorref];//边框颜色
    
#warning 出错
    UILabel *lbltable = [[UILabel alloc] init];
    lbltable.frame = CGRectMake(70, 25, 90, 20);
    lbltable.textColor = [UIColor greenColor];
    lbltable.backgroundColor = [UIColor clearColor];
    lbltable.font = [UIFont systemFontOfSize:14.0f];
    tableLable = lbltable;
    [self addSubview:tableLable];
    [lbltable release];
    
    UILabel *tpNumLable = [[UILabel alloc] init];
    tpNumLable.frame = CGRectMake(70, 50, 85, 20);
    tpNumLable.textColor = [UIColor blackColor];
    tpNumLable.backgroundColor = [UIColor clearColor];
    tpNumLable.font = [UIFont systemFontOfSize:12.0f];
    pNumLable = tpNumLable;
    [self addSubview:pNumLable];
    [tpNumLable release];
}

- (void)setTableType:(BSTableType)tableType_{
    if (tableType_!=tableType || (tableType==tableType_ && tableType==BSTableTypeOrdered)){
        [self _initView];
        tableType = tableType_;
        NSString *strImage = @"";;
        switch (tableType) {
            case BSTableTypeKongXian:
                strImage = @"kongxian.png";
                break;
            case BSTableTypeKaiTai:
               strImage = @"kaitai.png";
                break;
            case BSTableTypeDianCan:
                strImage = @"diancan.png";
                break;
            case BSTableTypeJieZhang:
                strImage = @"jiezhang.png";
                break;
            case BSTableTypeFengTai:
                strImage = @"fengtai.png";
                break;
            case BSTableTypeHuanTai:
                strImage = @"huantai.png";
                break;
            case BSTableTypeGuaDan:
                strImage = @"guadan.png";
                break;
            case BSTableTypeCaiQi:
                strImage = @"caiqi.png";
                break;
            default:
                break;
        }
        [imageView setImage:[UIImage imageNamed:strImage]];
    }
}


- (NSString *)tableTitle{
    return tableTitle;
}

- (void)setTableTitle:(NSString *)tableTitle_{
    if (tableTitle_!=tableTitle){
        [tableTitle release];
        tableTitle = [tableTitle_ copy];
//        [self setTitle:tableTitle forState:UIControlStateNormal];
        tableLable.text = tableTitle;
    }
}
-(NSString *)people{
    return people;
}

-(void)setPeople:(NSString *)people_{
    if (people_!=people) {
        [people release];
        people = [people_ copy];
        pNumLable.text = [NSString stringWithFormat:[langSetting localizedString:@"People number"],people];
    }
}

@end
