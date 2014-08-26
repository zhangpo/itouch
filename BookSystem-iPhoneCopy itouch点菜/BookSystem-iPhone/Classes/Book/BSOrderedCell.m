//
//  BSOrderedCell.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-30.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import "BSOrderedCell.h"
#import "AppDelegate.h"
#import "BSDataProvider.h"
#import "PackAdditionsViewController.h"
#import "CVLocalizationSetting.h"

@implementation BSOrderedCell
@synthesize dicInfo,delegate;

- (void)dealloc{
    self.dicInfo = nil;
    self.delegate = nil;
    
    [super dealloc];
}
- (void)setDicInfo:(NSDictionary *)dic{
    
    if (dicInfo!=dic){
        [dicInfo release];
        dicInfo = [[NSMutableDictionary dictionaryWithDictionary:dic] retain];
    }
    if (dic){
        [self showInfo:dic];
    }
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        langSetting = langSetting = [CVLocalizationSetting sharedInstance];
        float offset = 80;
        
        lblName = [UILabel createLabelWithFrame:CGRectMake(114-offset, 14, ScreenWidth+offset-114-10, 18) font:[UIFont boldSystemFontOfSize:17]];
        [self.contentView addSubview:lblName];
        
        lblPriceUnit = [UILabel createLabelWithFrame:CGRectMake(114-offset, 44, 190, 18) font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor colorWithRed:.71 green:0 blue:.18 alpha:1]];
        [self.contentView addSubview:lblPriceUnit];
        
        
        
        UILabel *lbl = [UILabel createLabelWithFrame:CGRectMake(225-offset, 44, 190, 18) font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor colorWithRed:.71 green:0 blue:.18 alpha:1]];
        [self.contentView addSubview:lbl];
        lbl.text = [langSetting localizedString:@"Count:"];
//        lbl.text = @"数量:";
        
        UIButton *btnCount = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"BSCountBG.png"];
//        UIImage* stretchableImage = [image stretchableImageWithLeftCapWidth:0 topCapHeight:5];
        
        [btnCount setBackgroundImage:image forState:UIControlStateNormal];
        [btnCount sizeToFit];
        btnCount.frame = CGRectMake(275-offset, 42, btnCount.frame.size.width+8, 25);
        [self.contentView addSubview:btnCount];
        [btnCount addTarget:self action:@selector(countClicked) forControlEvents:UIControlEventTouchUpInside];
        
        lblCount = [UILabel createLabelWithFrame:CGRectMake(10, 0, btnCount.frame.size.width-6, btnCount.frame.size.height) font:[UIFont systemFontOfSize:14]];
//        lblCount.textAlignment = NSTextAlignmentCenter;
        [btnCount addSubview:lblCount];
        
        
//        defaultPickerView = [[CPPickerView alloc] initWithFrame:CGRectMake(240-offset, 44, 60, 30)];
//        defaultPickerView.backgroundColor = [UIColor whiteColor];
//        defaultPickerView.dataSource = self;
//        defaultPickerView.delegate = self;
//        defaultPickerView.itemFont = [UIFont systemFontOfSize:13.0f];
//        [defaultPickerView reloadData];
//        [self.contentView addSubview:defaultPickerView];
        
        
        lblTotalPrice = [UILabel createLabelWithFrame:CGRectMake(114-offset, 69, 190, 18) font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor colorWithRed:.71 green:0 blue:.18 alpha:1]];
        [self.contentView addSubview:lblTotalPrice];
        
        UIButton *btnAdditions = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAdditions.frame = CGRectMake(114-offset, 87, 170, 30);
        btnAdditions.clipsToBounds = YES;
        btnAdditions.layer.cornerRadius = 5;
        btnAdditions.layer.borderWidth = 1;
        btnAdditions.layer.borderColor = [UIColor colorWithWhite:.82 alpha:1].CGColor;
        [self.contentView addSubview:btnAdditions];
        [btnAdditions addTarget:self action:@selector(additionsClicked) forControlEvents:UIControlEventTouchUpInside];
        
        lblAdditions = [UILabel createLabelWithFrame:CGRectMake(3, 0, btnAdditions.frame.size.width-6, btnAdditions.frame.size.height) font:[UIFont systemFontOfSize:14]];
        lblAdditions.textColor = lblTotalPrice.textColor;
        [btnAdditions addSubview:lblAdditions];
//        lblAdditions.text = @"附加项：";
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.frame = btnAdditions.bounds;
        [btnAdditions.layer insertSublayer:gradientLayer atIndex:0];
        [gradientLayer release];
        
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:1].CGColor,(id)[UIColor colorWithWhite:.93f alpha:1].CGColor,nil];
        gradientLayer.startPoint = CGPointZero;
        gradientLayer.endPoint = CGPointMake(0.0, 1);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(ScreenWidth - 78, 87, 60, 25);
        [btn setTitle:[langSetting localizedString:@"Delete"] forState:UIControlStateNormal];
//        [btn setTitle:@"删除" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deleteClicked) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderColor = [UIColor grayColor].CGColor;
        btn.layer.borderWidth = 1;
//        self.accessoryView = btn;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:btn];
    }
    
    return self;
}

- (void)showInfo:(NSDictionary *)info{
    if ([[info objectForKey:@"ISTC"] boolValue]) { //套餐
        lblAdditions.text = [langSetting localizedString:@"Details:"];
//        lblAdditions.text = @"详细：";
        lblName.text = [info objectForKey:@"DES"];
        int t = [[info objectForKey:@"total"] intValue];
        lblCount.text = [NSString stringWithFormat:@"%d",t];
        NSString *price = [NSString stringWithFormat:[langSetting localizedString:@"Price2"],[[info objectForKey:@"PRICE"] floatValue]];
        lblPriceUnit.text = price ;
        lblTotalPrice.text = [NSString stringWithFormat:[langSetting localizedString:@"total2"],[[info objectForKey:@"total"] floatValue]*[[info objectForKey:@"PRICE"] floatValue]];//合计：%.2f
        NSArray *foods = [info objectForKey:@"foods"];
         NSMutableString *mutstr = [NSMutableString string];
        [mutstr appendString:[langSetting localizedString:@"Details:"]];  //[mutstr appendString:@"详细："];
        for (int i=0;i<foods.count;i++){
            [mutstr appendString:0==i?[[foods objectAtIndex:i] objectForKey:@"PNAME"]:[NSString stringWithFormat:@",%@",[[foods objectAtIndex:i] objectForKey:@"PNAME"]]];
        }
        lblAdditions.text = mutstr;
        
    }else{
        lblAdditions.text = [langSetting localizedString:@"Additions:"];//附加项
//        lblAdditions.text = @"附加项：";
        NSDictionary *foodInfo = [info objectForKey:@"food"];
        
        lblName.text = [foodInfo objectForKey:@"DES"];
        int t = [[info objectForKey:@"total"] intValue];
        lblCount.text = [NSString stringWithFormat:@"%d",t];
        lblPriceUnit.text =  [NSString stringWithFormat:[langSetting localizedString:@"Price3"],[[foodInfo objectForKey:[info objectForKey:@"priceKey"]] floatValue],[foodInfo objectForKey:[info objectForKey:@"unitKey"]]];//@"价格：%.2f/%@"
        if ([[[info objectForKey:@"food"] objectForKey:@"UNITCUR"] isEqualToString:@"2"]) {
            lblTotalPrice.text = [NSString stringWithFormat:[langSetting localizedString:@"total2"],[[[info objectForKey:@"food"] objectForKey:@"UNITCUR"] floatValue]*[[[info objectForKey:@"food"] objectForKey:@"PRICE"] floatValue]];
        }else{
            lblTotalPrice.text = [NSString stringWithFormat:[langSetting localizedString:@"total2"],[[info objectForKey:@"total"] floatValue]*[[foodInfo objectForKey:[info objectForKey:@"priceKey"]] floatValue]];
        }
        //@"合计： %.2f"
        NSArray *additions = [info objectForKey:@"addition"];
        NSMutableString *mutstr = [NSMutableString string];
        [mutstr appendString:[langSetting localizedString:@"Additions:"]];//附加项
        for (int i=0;i<additions.count;i++){
            [mutstr appendString:0==i?[[additions objectAtIndex:i] objectForKey:@"FoodFuJia_Des"]:[NSString stringWithFormat:@",%@",[[additions objectAtIndex:i] objectForKey:@"FoodFuJia_Des"]]];
        }
        lblAdditions.text = mutstr;
    }
    
    
    //    lblAddition.text = [NSString stringWithFormat:@"%@,%@",[dic objectForKey:@"add1"],[dic objectForKey:@"add2"]];
}

- (void)countClicked{
    if ([[[dicInfo objectForKey:@"food"] objectForKey:@"UNITCUR"] isEqualToString:@"2"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"The second unit are not increased in the food"] message:nil delegate:self cancelButtonTitle:[langSetting localizedString:@"Cancel"] otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    vPicker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.delegate.view.frame.size.height)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, vPicker.frame.size.height-218-44, ScreenWidth, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [vPicker addSubview:toolbar];
    [toolbar release];
    //    toolbar.userInteractionEnabled = NO;
    
    lblSelection = [UILabel createLabelWithFrame:CGRectMake(0, 0, ScreenWidth, 44) font:[UIFont boldSystemFontOfSize:13] textColor:[UIColor whiteColor]];
    lblSelection.textAlignment = NSTextAlignmentCenter;
    [toolbar addSubview:lblSelection];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"ABNavButtonBG.png"] forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setTitle:[langSetting localizedString:@"Cancel"] forState:UIControlStateNormal]; //取消
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(10+btn.frame.size.width/2, 22);
    [toolbar addSubview:btn];
    //    btn.hidden = YES;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"ABNavButtonBG.png"] forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn setTitle:[langSetting localizedString:@"OK"] forState:UIControlStateNormal];//确定
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(ScreenWidth-10-btn.frame.size.width/2, 22);
    [toolbar addSubview:btn];

    //    btn.hidden = YES;
    UIPickerView *picker = [[UIPickerView alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        picker.frame = CGRectMake(0, vPicker.frame.size.height-218, ScreenWidth, 218) ;
    }else{
         picker.frame = CGRectMake(0, vPicker.frame.size.height-218, ScreenWidth, 218) ;
    }
    
    picker.showsSelectionIndicator = YES;
    picker.backgroundColor = [UIColor grayColor];
    picker.delegate = self;
    picker.dataSource = self;
    [vPicker addSubview:picker];
    [picker release];
    
    vPicker.frame = CGRectMake(0, vPicker.frame.size.height, vPicker.frame.size.width, vPicker.frame.size.height);
    [self.delegate.view addSubview:vPicker];
    [vPicker release];
    
    [UIView animateWithDuration:.3f animations:^{
       vPicker.frame = CGRectMake(0, 0, vPicker.frame.size.width, vPicker.frame.size.height);
    }];
    
}


- (void)additionsClicked{
    if ([[dicInfo objectForKey:@"ISTC"] boolValue]) {
        if ([self.delegate respondsToSelector:@selector(Additions:)]) {
            [self.delegate Additions:self];
        }
    }else{
        BSAdditionsView *v = [BSAdditionsView additionsViewWithDelegate:self additions:[dicInfo objectForKey:@"addition"]];
        [v show];
    }
}


- (void)cancelClicked{
    [UIView animateWithDuration:.3f animations:^{
        vPicker.frame = CGRectMake(0, vPicker.frame.size.height, vPicker.frame.size.width, vPicker.frame.size.height);
    }completion:^(BOOL finished) {
        [vPicker removeFromSuperview];
        vPicker = nil;
    }];
}

- (void)confirmClicked{
    [UIView animateWithDuration:.3f animations:^{
        vPicker.frame = CGRectMake(0, vPicker.frame.size.height, vPicker.frame.size.width, vPicker.frame.size.height);
    }completion:^(BOOL finished) {
        [vPicker removeFromSuperview];
        vPicker = nil;
    }];
    
    lblCount.text = [NSString stringWithFormat:@"%d",fCount];
    lblTotalPrice.text = [NSString stringWithFormat:[langSetting localizedString:@"total2"],[[[dicInfo objectForKey:@"food"] objectForKey:[dicInfo objectForKey:@"priceKey"]] floatValue]*fCount];
    
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
    [mut setObject:[NSString stringWithFormat:@"%d",fCount] forKey:@"total"];
    
    self.dicInfo = (NSMutableDictionary *)[NSDictionary dictionaryWithDictionary:mut];
    
    if ([delegate respondsToSelector:@selector(cellUpdated:)])
        [delegate cellUpdated:self];
    
}

- (void)deleteClicked{
    fCount = 0;
    NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:dicInfo];
    [mut setObject:[NSString stringWithFormat:@"%d",fCount] forKey:@"total"];
    
    self.dicInfo = (NSMutableDictionary *)[NSDictionary dictionaryWithDictionary:mut];
    
    if ([delegate respondsToSelector:@selector(cellUpdated:)])
        [delegate cellUpdated:self];
}


#pragma mark UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d",row];
}


-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (!view)
        {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 50, 30)];
            label.text = [NSString stringWithFormat:@"%d",row];
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:17.0f];
            label.textAlignment = NSTextAlignmentCenter;
            view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
            view.backgroundColor = [UIColor whiteColor];
            [view addSubview:label];
        }
    }else{
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 50, 30)];
        label.text = [NSString stringWithFormat:@" %d",row];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:17.0f];
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
        view.backgroundColor = [UIColor whiteColor];
        [view addSubview:label];
    }
    return view ;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0f;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    return 0==component?10:10;
    return 10;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 0==component?60:60;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    int value;
    
    int index0 = [pickerView selectedRowInComponent:0];
    int index1 = [pickerView selectedRowInComponent:1];
    int index2 = [pickerView selectedRowInComponent:2];
    
    value = index0*100+index1*10+index2;
    
    
    fCount = value;
    lblSelection.text = [NSString stringWithFormat:@"%d",fCount];
}



#pragma mark - BSAdditionsView Delegate
- (void)additionsSelected:(NSArray *)additions{
    if (additions.count>0)
        [dicInfo setObject:additions forKey:@"addition"];
    else
        [dicInfo removeObjectForKey:@"addition"];
    
    if ([delegate respondsToSelector:@selector(cellUpdated:)])
        [delegate cellUpdated:self];
}

@end
