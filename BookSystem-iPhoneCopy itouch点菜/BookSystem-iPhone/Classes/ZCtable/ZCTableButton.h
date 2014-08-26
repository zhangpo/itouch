//
//  BSTableButtion.h
//  BookSystem
//
//  Created by Dream on 11-7-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum{
//    BSTableTypeOrdered,      //blue
//    BSTableTypeEating,        //red
//    BSTableTypeEmpty,        //green
//    BSTableTypeNoOrder,       //yellow
//    BSTableTypeNotPaid      //purple
//}BSTableType;

typedef enum{
    ZCTableTypeOrdered=0,
    ZCTableTypeKongXian=2,
    ZCTableTypeKaiTai=4,
    ZCTableTypeDianCai=1,
    ZCTableTypeYuDing=3
}ZCTableType;

@class ZCTableButton;

@protocol ZCTableButtonDelegate

//- (void)tableClicked:(BSTableButton *)btn;
- (int)indexOfButtonCoveredPoint:(CGPoint)pt;

- (void)replaceOldTable:(int)oldIndex withNewTable:(int)newIndex;

@end

@interface ZCTableButton : UIButton {
    ZCTableType   tableType;
    
    NSString *tableTitle;
    
    id<ZCTableButtonDelegate> delegate;
    
    BOOL isMoving;
    
    CGPoint ptStart;
    
    UIImageView *imgvCopy;
    UIImageView *imageView;
    UILabel *tableLable;
    UILabel *pNumLable;
}


@property (nonatomic,assign) ZCTableType tableType;
@property (nonatomic,copy) NSString *tableTitle;
@property (nonatomic,assign) id<ZCTableButtonDelegate> delegate;
@end
