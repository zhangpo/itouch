//
//  BSTableButtion.h
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

//typedef enum{
//    BSTableTypeOrdered,      //blue
//    BSTableTypeEating,        //red
//    BSTableTypeEmpty,        //green
//    BSTableTypeNoOrder,       //yellow
//    BSTableTypeNotPaid      //purple
//}BSTableType;

typedef enum{
    BSTableTypeOrdered=0,
    BSTableTypeKongXian=1,
    BSTableTypeKaiTai=2,
    BSTableTypeDianCan=3,
    BSTableTypeJieZhang=4,
    BSTableTypeFengTai=6,
    BSTableTypeHuanTai=7,
    BSTableTypeGuaDan=9,
    BSTableTypeCaiQi=10
}BSTableType;

@class BSTableButton;

@protocol BSTableButtonDelegate

//- (void)tableClicked:(BSTableButton *)btn;
- (int)indexOfButtonCoveredPoint:(CGPoint)pt;

- (void)replaceOldTable:(int)oldIndex withNewTable:(int)newIndex;

@end

@interface BSTableButton : UIButton {
    BSTableType   tableType;
    
    NSString *tableTitle;
    NSString *people;
    id<BSTableButtonDelegate> delegate;
    
    BOOL isMoving;
    
    CGPoint ptStart;
    
    UIImageView *imgvCopy;
    UIImageView *imageView;
    UILabel *tableLable;
    UILabel *pNumLable;
    CVLocalizationSetting *langSetting;
}


@property (nonatomic,assign) BSTableType tableType;
@property (nonatomic,copy) NSString *tableTitle;
@property (nonatomic,copy) NSString *people;
@property (nonatomic,assign) id<BSTableButtonDelegate> delegate;
@end
