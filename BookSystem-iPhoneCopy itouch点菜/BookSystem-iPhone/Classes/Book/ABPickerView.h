//
//  ABPickerView.h
//  AiBa
//
//  Created by Wu Stan on 12-1-4.
//  Copyright (c) 2012年 CheersDigi. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
typedef enum{
    //基本资料
    ABInfoTypeBirthday,//出生日期
    ABInfoTypeHeight,//身高
    ABInfoTypeArea,//居住地
    ABInfoTypeWork,//职业
    ABInfoTypeNation,//民族
    ABInfoTypeSchool,//毕业学校
    ABInfoTypeHouse,//居住情况
    ABInfoTypeWedlock,//婚史
    ABInfoTypeEducation,//学历
    ABInfoTypeSalary,//月收入
    ABInfoTypeNativeArea,//籍贯
    ABInfoTypeBlood,//血型
    ABInfoTypeStatus,//征婚状态
    
    
    
    ABInfoTypePersonal=100,//个性
    
    
    
}ABInfoType;

typedef enum {
    ABMateInfoTypeAge = 13,//年龄
    ABMateInfoTypeHeight,//身高
    ABMateInfoTypeArea,//居住地
    ABMateInfoTypeLevel,//诚信级别
    ABMateInfoTypeHouse,//住房情况
    ABMateInfoTypeWedlock,//婚史
    ABMateInfoTypeEducation,//学历
    ABMateInfoTypeSalary,//月收入
    ABMateInfoTypeNativeArea//籍贯 
}ABMateInfoType;

typedef enum {
    ABSearchInfoTypeGender = 22,//性别
    ABSearchInfoTypeAge,//年龄
    ABSearchInfoTypeHeight,//身高
    ABSearchInfoTypeArea,//居住地
    ABSearchInfoTypeLevel,//诚信级别
    ABSearchInfoTypeHouse,//住房情况
    ABSearchInfoTypeWedlock,//婚史
    ABSearchInfoTypeEducation,//学历
    ABSearchInfoTypeSalary,//月收入
    ABSearchInfoTypeNativeArea//籍贯
    
    
    
    
}ABSearchInfoType;
*/

typedef enum {
    //  基本资料
    ABEditTypeNickname,
    ABEditTypeBirthday,
    ABEditTypeHeight,
    ABEditTypeArea,
    ABEditTypeWork,
    ABEditTypeNation,
    ABEditTypeSchool,
    ABEditTypeHouse,
    ABEditTypeWedlock,
    ABEditTypeEducation,
    ABEditTypeSalary,
    ABEditTypeNativeArea,
    ABEditTypeBlood,
    ABEditTypeStatus,
    ABEditTypeAuthority,
    ABEditTypeIntroduction,
    //  择偶条件
    ABEditTypeMateAge,
    ABEditTypeMateHeight,
    ABEditTypeMateArea,
    ABEditTypeMateLevel,
    ABEditTypeMateHouse,
    ABEditTypeMateWedlock,
    ABEditTypeMateEducation,
    ABEditTypeMateSalary,
    ABEditTypeMateNativeArea,
    //  搜索条件
    ABEditTypeSearchGender,
    ABEditTypeSearchAge,
    ABEditTypeSearchHeight,
    ABEditTypeSearchArea,
    ABEditTypeSearchLevel,
    ABEditTypeSearchHouse,
    ABEditTypeSearchWedlock,
    ABEditTypeSearchEducation,
    ABEditTypeSearchSalary,
    ABEditTypeSearchNativeArea,
    //  约会
    ABEditTypeDateContent
}ABEditType;

@class ABPickerView;

@protocol ABPickerViewDelegate

- (void)pickerDidFinishSelection:(ABPickerView *)picker;
- (void)pickerDidCancelSelection:(ABPickerView *)picker;
- (void)pickerDidChangedSelection:(ABPickerView *)picker;

@end

@interface ABPickerView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>{
    UIPickerView *pickerInfo;
    UIDatePicker *pickerDate;
    UILabel *lblSelection;
    
    ABEditType editType;
    NSMutableDictionary *dicInfo;
    NSDictionary *dicProfile,*dicProfileMate,*dicProfileSearch;
    id<ABPickerViewDelegate> delegate;
    NSUInteger dMinAge,dMaxAge,dMinHeight,dMaxHeight;
}
@property (nonatomic,retain) NSMutableDictionary *dicInfo;
@property (nonatomic,retain) NSDictionary *dicProfile,*dicProfileMate,*dicProfileSearch;
@property ABEditType editType;
@property (nonatomic,assign) id<ABPickerViewDelegate> delegate;
@property (nonatomic,assign) UIPickerView *pickerInfo;
@property (nonatomic,assign) UIDatePicker *pickerDate;
@property (nonatomic,assign) UILabel *lblSelection;


- (void)setDate:(NSDate *)date;
- (void)setProvince:(int)province city:(int)city;

@end
