//
//  BSTableButtion.m
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ZCTableButton.h"


@implementation ZCTableButton
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



- (ZCTableType)tableType{
    return tableType;
}

-(void)_initView{
    imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(10, 20, 60, 60);
    [self addSubview:imageView];
    
    self.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:0]; //设置矩形四个圆角半径
    [self.layer setBorderWidth:0]; //边框宽度
//    [self.layer setBorderColor:colorref];//边框颜色
    
    tableLable = [[UILabel alloc] init];
    tableLable.frame = CGRectMake(70, 25, 90, 20);
    tableLable.textColor = [UIColor greenColor];
    tableLable.backgroundColor = [UIColor clearColor];
    tableLable.font = [UIFont systemFontOfSize:16.0f];
//    tableLable.text = @"121212sssddddfff";
    [self addSubview:tableLable];
    
    pNumLable = [[UILabel alloc] init];
    pNumLable.frame = CGRectMake(70, 50, 85, 20);
    pNumLable.textColor = [UIColor blackColor];
    pNumLable.backgroundColor = [UIColor clearColor];
    pNumLable.font = [UIFont systemFontOfSize:12.0f];
    pNumLable.text = @"就餐人数：10";
    [self addSubview:pNumLable];
}

- (void)setTableType:(ZCTableType)tableType_{
    if (tableType_!=tableType || (tableType==tableType_ && tableType==ZCTableTypeOrdered)){
        [self _initView];
        tableType = tableType_;
        NSString *strImage;
        switch (tableType) {
            case ZCTableTypeKongXian:
                strImage = @"kongxian.png";
                break;
            case ZCTableTypeKaiTai:
               strImage = @"kaitai.png";
                break;
            case ZCTableTypeDianCai:
                strImage = @"diancan.png";
                break;
            case ZCTableTypeYuDing:
                strImage = @"huantai.png";
                break;

            default:
                strImage = @"fengtai.png";
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

@end
