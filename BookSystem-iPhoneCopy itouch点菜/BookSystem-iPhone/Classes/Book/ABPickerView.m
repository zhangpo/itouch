//
//  ABPickerView.m
//  AiBa
//
//  Created by Wu Stan on 12-1-4.
//  Copyright (c) 2012年 CheersDigi. All rights reserved.
//

#import "ABPickerView.h"

@implementation ABPickerView
@synthesize dicInfo,dicProfile,delegate,pickerInfo,pickerDate,lblSelection,dicProfileMate,dicProfileSearch;

- (void)dealloc{
    self.dicInfo = nil;
    self.dicProfile = nil;
    self.dicProfileMate = nil;
    self.dicProfileSearch = nil;
    [super dealloc];
}

- (ABEditType)editType{
    return editType;
}

- (void)setProvince:(int)province city:(int)city{
    [pickerInfo selectRow:province inComponent:0 animated:NO];
    
    NSArray *cities = [[[dicProfile objectForKey:@"city"] objectAtIndex:province] objectForKey:@"cities"];
    NSArray *allcities = [dicProfile objectForKey:@"cities"];
    
    int dcity = -1;
    if (0==city)
        dcity = 0;
    else{
        for (int i=0;i<cities.count;i++){
            if ([[cities objectAtIndex:i] isEqualToString:[allcities objectAtIndex:city]]){
                dcity = i+1;
            }
        }
    }
    [pickerInfo reloadComponent:1];
    [pickerInfo selectRow:dcity>0?dcity:0 inComponent:1 animated:NO];
}

- (void)setEditType:(ABEditType)type{
    editType = type;
    
    pickerInfo.hidden = (ABEditTypeBirthday==type);
    pickerDate.hidden = !pickerInfo.hidden;
    [pickerInfo selectRow:0 inComponent:0 animated:NO];
    [pickerInfo reloadAllComponents];
    
    NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:-3600*24*365*18];
    pickerDate.datePickerMode = UIDatePickerModeDate;
    pickerDate.maximumDate = maxDate;
    
    switch (editType) {
        case ABEditTypeHeight:{
            int height = [[dicInfo objectForKey:@"height"] intValue];
            if (height>=120)
                [pickerInfo selectRow:height-120 inComponent:0 animated:NO];
            else
                [pickerInfo selectRow:55 inComponent:0 animated:NO];
        }
            break;
        case ABEditTypeMateAge:{
            [pickerInfo selectRow:5 inComponent:0 animated:NO];
            [pickerInfo selectRow:12 inComponent:1 animated:NO];
        }
            break;
        case ABEditTypeMateHeight:{
            [pickerInfo selectRow:41 inComponent:0 animated:NO];
            [pickerInfo selectRow:61 inComponent:1 animated:NO];
        }
            break;
        default:
            break;
    }
}
    


- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = 320;
    frame.size.height = 260;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        dMaxAge = 80;
        dMinAge = 18;
        dMaxHeight = 250;
        dMinHeight = 120;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ProfileInfo.plist" ofType:nil];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        self.dicProfile = [dict objectForKey:@"basic"];
        self.dicProfileMate = [dict objectForKey:@"mate"];
        self.dicProfileSearch = [dict objectForKey:@"search"];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        [self addSubview:toolbar];
        [toolbar release];
        toolbar.userInteractionEnabled = NO;
        
        lblSelection = [UILabel createLabelWithFrame:CGRectMake(0, 0, 320, 44) font:[UIFont boldSystemFontOfSize:20] textColor:[UIColor whiteColor]];
        lblSelection.textAlignment = NSTextAlignmentCenter;
        [toolbar addSubview:lblSelection];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"ABNavButtonBG.png"] forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
        btn.center = CGPointMake(10+btn.frame.size.width/2, 22);
        [self addSubview:btn];
        btn.hidden = YES;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"ABNavButtonBG.png"] forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        btn.center = CGPointMake(320-10-btn.frame.size.width/2, 22);
        [self addSubview:btn];
        btn.hidden = YES;
        
        pickerInfo = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 320, 216)];
        pickerInfo.showsSelectionIndicator = YES;
        pickerInfo.delegate = self;
        pickerInfo.dataSource = self;
        [self addSubview:pickerInfo];
        [pickerInfo release];
        
        pickerDate = [[UIDatePicker alloc] initWithFrame:pickerInfo.frame];
        [pickerDate addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
        pickerDate.datePickerMode = UIDatePickerModeDate;
        [self addSubview:pickerDate];
        [pickerDate release];
    }
    return self;
}


- (void)cancelClicked{
    [delegate pickerDidCancelSelection:self];
}

- (void)confirmClicked{
    [delegate pickerDidFinishSelection:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray *ary = nil;
    NSString *title = nil;
    
    switch (editType) {
        case ABEditTypeBirthday:{
            
        }
            break;
        case ABEditTypeHeight:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=120;i<250;i++)
                [mut addObject:[NSString stringWithFormat:@"%dCM",i]];
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeNation:{
            ary = [dicProfile objectForKey:@"nation"];
        }
            break;
        case ABEditTypeArea:
        case ABEditTypeNativeArea:
        case ABEditTypeMateArea:
        case ABEditTypeMateNativeArea:
        case ABEditTypeSearchArea:
        case ABEditTypeSearchNativeArea:{
            int index = [pickerView selectedRowInComponent:0];
            if (0==component)
                title = [[dicProfile objectForKey:@"provinces"] objectAtIndex:row];
            else{
                if (0==row)
                    title = @"未填";
                else
                    title = [[[[dicProfile objectForKey:@"city"] objectAtIndex:index] objectForKey:@"cities"] objectAtIndex:row-1];
            }
        }
        case ABEditTypeEducation:
        case ABEditTypeMateEducation:
        case ABEditTypeSearchEducation:{
            ary = [dicProfile objectForKey:@"education"];
        }
            break;
        case ABEditTypeSchool:{
            
        }
            break;
        case ABEditTypeWork:{
            ary = [dicProfile objectForKey:@"work"];
        }
            break;
        case ABEditTypeSalary:
        case ABEditTypeMateSalary:
        case ABEditTypeSearchSalary:{
            ary = [dicProfile objectForKey:@"salary"];
        }
            break;
        case ABEditTypeHouse:
            ary = [dicProfile objectForKey:@"house"];
            break;
        case ABEditTypeMateHouse:
        case ABEditTypeSearchHouse:{
            ary = [dicProfileSearch objectForKey:@"house"];
        }
            break;
        
//        case ABEditTypePersonal:{
//            ary = [dicProfile objectForKey:@"personal"];
//        }
//            break;
        case ABEditTypeBlood:{
            ary = [dicProfile objectForKey:@"blood"];
        }
            break;
        case ABEditTypeWedlock:
        case ABEditTypeMateWedlock:
        case ABEditTypeSearchWedlock:{
            ary = [dicProfile objectForKey:@"wedlock"];
        }
            break;
        case ABEditTypeStatus:{
            ary = [dicProfile objectForKey:@"status"];
        }
            break;
            
        
        case ABEditTypeMateAge:
        case ABEditTypeSearchAge:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:@"不限"];
                for (int i=18;i<=dMaxAge;i++)
                    [mut addObject:[NSString stringWithFormat:@">=%d岁",i]];
                ary = [NSArray arrayWithArray:mut];
            }
                
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:@"不限"];
                for (int i=dMinAge;i<=80;i++)
                    [mut addObject:[NSString stringWithFormat:@"<=%d岁",i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateHeight:
        case ABEditTypeSearchHeight:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:@"不限"];
                for (int i=120;i<=dMaxHeight;i++)
                    [mut addObject:[NSString stringWithFormat:@">=%dCM",i]];
                ary = [NSArray arrayWithArray:mut];
            }
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:@"不限"];
                for (int i=dMinHeight;i<=250;i++)
                    [mut addObject:[NSString stringWithFormat:@"<=%dCM",i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateLevel:
        case ABEditTypeSearchLevel:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=0;i<=5;i++){
                if (0!=i)
                    [mut addObject:[NSString stringWithFormat:@"%d或以上",i]];
                else
                    [mut addObject:@"不限"];
            }
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeSearchGender:{
            ary = [NSArray arrayWithObjects:@"男",@"女", nil];
        }
            break;
        default:
            break;
    }
        

    
    if (!title && [ary count]>row)
        title = [ary objectAtIndex:row];
    
    if (!title)
        title = @"未填";
    
    return title;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSArray *ary = nil;

    
    switch (editType) {
        case ABEditTypeBirthday:{
            
        }
            break;
        case ABEditTypeHeight:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=120;i<250;i++)
                [mut addObject:[NSString stringWithFormat:@"%dCM",i]];
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeNation:{
            ary = [dicProfile objectForKey:@"nation"];
        }
            break;
        case ABEditTypeArea:
        case ABEditTypeNativeArea:
        case ABEditTypeMateArea:
        case ABEditTypeMateNativeArea:
        case ABEditTypeSearchArea:
        case ABEditTypeSearchNativeArea:{
            if (0==component)
                return [[dicProfile objectForKey:@"city"] count];
            else{
                int index = [pickerView selectedRowInComponent:0];
                return [[[[dicProfile objectForKey:@"city"] objectAtIndex:index] objectForKey:@"cities"] count]+1;
            }
        }
        case ABEditTypeEducation:
        case ABEditTypeMateEducation:
        case ABEditTypeSearchEducation:{
            ary = [dicProfile objectForKey:@"education"];
        }
            break;
        case ABEditTypeSchool:{
            
        }
            break;
        case ABEditTypeWork:{
            ary = [dicProfile objectForKey:@"work"];
        }
            break;
        case ABEditTypeSalary:
        case ABEditTypeMateSalary:
        case ABEditTypeSearchSalary:{
            ary = [dicProfile objectForKey:@"salary"];
        }
            break;
        case ABEditTypeHouse:
        case ABEditTypeMateHouse:
        case ABEditTypeSearchHouse:{
            ary = [dicProfile objectForKey:@"house"];
        }
            break;
//        case ABEditTypePersonal:{
//            ary = [dicProfile objectForKey:@"personal"];
//        }
//            break;
        case ABEditTypeBlood:{
            ary = [dicProfile objectForKey:@"blood"];
        }
            break;
        case ABEditTypeWedlock:
        case ABEditTypeMateWedlock:
        case ABEditTypeSearchWedlock:{
            ary = [dicProfile objectForKey:@"wedlock"];
        }
            break;
        case ABEditTypeStatus:{
            ary = [dicProfile objectForKey:@"status"];
        }
            break;
        case ABEditTypeMateAge:
        case ABEditTypeSearchAge:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:@"不限"];
                for (int i=18;i<=dMaxAge;i++)
                    [mut addObject:[NSString stringWithFormat:@">=%d岁",i]];
                ary = [NSArray arrayWithArray:mut];
            }
            
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:@"不限"];
                for (int i=dMinAge;i<=80;i++)
                    [mut addObject:[NSString stringWithFormat:@"<=%d岁",i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateHeight:
        case ABEditTypeSearchHeight:{
            if (0==component){
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:@"不限"];
                for (int i=120;i<=dMaxHeight;i++)
                    [mut addObject:[NSString stringWithFormat:@">=%dCM",i]];
                ary = [NSArray arrayWithArray:mut];
            }
            else{
                NSMutableArray *mut = [NSMutableArray array];
                [mut addObject:@"不限"];
                for (int i=dMinHeight;i<=250;i++)
                    [mut addObject:[NSString stringWithFormat:@"<=%dCM",i]];
                ary = [NSArray arrayWithArray:mut];
            }
        }
            break;
        case ABEditTypeMateLevel:
        case ABEditTypeSearchLevel:{
            NSMutableArray *mut = [NSMutableArray array];
            for (int i=0;i<=5;i++){
                if (0!=i)
                    [mut addObject:[NSString stringWithFormat:@"%d或以上",i]];
                else
                    [mut addObject:@"不限"];
            }
            ary = [NSArray arrayWithArray:mut];
        }
            break;
        case ABEditTypeSearchGender:{
            ary = [NSArray arrayWithObjects:@"男",@"女", nil];
        }
            break;
        default:
            break;
    }
    

    
    return [ary count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (ABEditTypeMateAge==editType || ABEditTypeSearchAge==editType ||
        ABEditTypeMateHeight==editType || ABEditTypeSearchHeight==editType ||
        ABEditTypeArea==editType || ABEditTypeMateArea==editType || ABEditTypeSearchArea==editType ||
        ABEditTypeNativeArea==editType || ABEditTypeMateNativeArea==editType || ABEditTypeSearchNativeArea==editType)
        return 2;
    else
        return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (ABEditTypeMateAge==editType || ABEditTypeSearchAge==editType){
        NSString *title = [self pickerView:pickerView titleForRow:row forComponent:component];
        int count = 0;
        if ([[title componentsSeparatedByString:@"="] count]>1){
            count = [[[title componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
        }
        
        if (0==component){
            int min = count;
            if (0!=min)
                dMinAge = min;
            if (dMaxAge<dMinAge)
                dMaxAge = dMinAge;
        }else{
            int max = count;
            if (0!=max)
                dMaxAge = max;
            if (dMinAge>dMaxAge)
                dMinAge = dMaxAge;
        }
        
        [pickerView reloadAllComponents];
    }else if (ABEditTypeMateHeight==editType || ABEditTypeSearchHeight==editType){
        NSString *title = [self pickerView:pickerView titleForRow:row forComponent:component];
        int count = 0;
        if ([[title componentsSeparatedByString:@"="] count]>1){
            count = [[[title componentsSeparatedByString:@"="] objectAtIndex:1] intValue];
        }
        
        if (0==component){
            int min = count;
            if (0!=min)
                dMinHeight = min;
            if (dMaxHeight<dMinHeight)
                dMaxHeight = dMinHeight;
        }else{
            int max = count;
            if (0!=max)
                dMaxHeight = max;
            if (dMinHeight>dMaxHeight)
                dMinHeight = dMaxHeight;
        }
        
        [pickerView reloadAllComponents];
    }else if (ABEditTypeArea==editType || ABEditTypeMateArea==editType || ABEditTypeSearchArea==editType || ABEditTypeNativeArea==editType || ABEditTypeMateNativeArea==editType || ABEditTypeSearchNativeArea==editType)
        [pickerView reloadComponent:1];
    
    [delegate pickerDidChangedSelection:self];
}

- (void)dateChanged{
    [delegate pickerDidChangedSelection:self];
}

- (void)setDate:(NSDate *)date{
    [pickerDate setDate:date];
}
@end
