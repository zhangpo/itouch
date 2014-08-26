//
//  BSChunkView.m
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ZCChuckView.h"
#import "BSDataProvider.h"
#import "CVLocalizationSetting.h"


@implementation ZCChuckView
@synthesize delegate;
@synthesize aryReasons;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    langSetting = [CVLocalizationSetting sharedInstance];
    if (self) {
        [self setTitle:[langSetting localizedString:@"Chuck"]];
        dSelected = 0;
        
        BSDataProvider *dp = [BSDataProvider sharedInstance];
        NSMutableArray *ary = [dp getCodeDesc];
        NSMutableArray *aryList = [NSMutableArray array];
        for (NSDictionary *dic in ary){
            if ([[dic objectForKey:@"CODE"] isEqualToString:@"XT"])
                [aryList addObject:dic];
        }
        self.aryReasons = [NSMutableArray arrayWithArray:aryList];
        
        lblAcct = [[UILabel alloc] initWithFrame:CGRectMake(10, 53, 65, 25)];
        lblAcct.textAlignment = UITextAlignmentRight;
        lblAcct.backgroundColor = [UIColor clearColor];
        lblAcct.font = [UIFont systemFontOfSize:15.0f];
        lblAcct.text = [langSetting localizedString:@"user code"];
        [self addSubview:lblAcct];
        [lblAcct release];
        tfAcct = [[UITextField alloc] initWithFrame:CGRectMake(80, 53, 60, 25)];
        tfAcct.borderStyle = UITextBorderStyleRoundedRect;
        tfAcct.keyboardType = UIKeyboardTypeNamePhonePad;
        [self addSubview:tfAcct];
        [tfAcct release];
        
        lblPwd = [[UILabel alloc] initWithFrame:CGRectMake(140, 53, 40, 25)];
        lblPwd.textAlignment = UITextAlignmentRight;
        lblPwd.backgroundColor = [UIColor clearColor];
        lblPwd.font = [UIFont systemFontOfSize:15.0f];
        lblPwd.text = [langSetting localizedString:@"Password:"];
        [self addSubview:lblPwd];
        [lblPwd release];
        tfPwd = [[UITextField alloc] initWithFrame:CGRectMake(190, 53, 70, 25)];
        tfPwd.borderStyle = UITextBorderStyleRoundedRect;
        tfPwd.secureTextEntry = YES;
        [self addSubview:tfPwd];
        [tfPwd release];
        
        lblCount = [[UILabel alloc] initWithFrame:CGRectMake(20, 83, 50, 25)];
        lblCount.textAlignment = UITextAlignmentRight;
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.font = [UIFont systemFontOfSize:15.0f];
        lblCount.text = [langSetting localizedString:@"Count:"];
        [self addSubview:lblCount];
        [lblCount release];
        tfCount = [[UITextField alloc] initWithFrame:CGRectMake(80, 83, 60, 25)];
        tfCount.borderStyle = UITextBorderStyleRoundedRect;
        tfCount.keyboardType = UIKeyboardTypeDecimalPad;
        [self addSubview:tfCount];
        [tfCount release];
        
        lblReason = [[UILabel alloc] initWithFrame:CGRectMake(10, 107, 50, 25)];
        lblReason.textAlignment = UITextAlignmentRight;
        lblReason.backgroundColor = [UIColor clearColor];
        lblReason.font = [UIFont systemFontOfSize:15.0f];
        lblReason.text = [langSetting localizedString:@"Reason:"];
        [self addSubview:lblReason];
        [lblReason release];
        
        tfCount.delegate = self;
        tfPwd.delegate = self;
        tfAcct.delegate = self;
        
        btnChunk = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnChunk.frame = CGRectMake(75, 250, 40, 30);
        [btnChunk setTitle:[langSetting localizedString:@"Chuck"] forState:UIControlStateNormal];
        [self addSubview:btnChunk];
        btnChunk.tag = 700;
        [btnChunk addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(160, 250, 40, 30);
        [btnCancel setTitle:[langSetting localizedString:@"Cancel"] forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
        pickerReason = [[UIPickerView alloc] initWithFrame:CGRectMake(50, 100, 180, 100)];
        pickerReason.showsSelectionIndicator = YES;
        pickerReason.dataSource= self;
        pickerReason.delegate = self;
        [self addSubview:pickerReason];
        [pickerReason release];
        
        tfAcct.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
        tfPwd.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"password"];
        
        UIControl *control=[[UIControl alloc]initWithFrame:self.bounds];
        [control addTarget:self action:@selector(controlClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        [self sendSubviewToBack:control];
    }
    return self;
}

-(void)controlClick
{
    [tfAcct resignFirstResponder];
    [tfCount resignFirstResponder];
    [tfPwd resignFirstResponder];
}


- (void)dealloc
{
    self.aryReasons = nil;
    [super dealloc];
}

- (void)confirm{
    BOOL bAuth = NO;
    if ([tfAcct.text length]>0 && [tfPwd.text length]>0)
        bAuth = YES;
    
    if (bAuth){
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:tfAcct.text,@"user",tfPwd.text,@"pwd",@"send",@"send",nil];
        if ([tfCount.text length]>0){
            [dic setObject:tfCount.text forKey:@"total"];
        }
        [dic setObject:[[self.aryReasons objectAtIndex:dSelected] objectForKey:@"SNO"] forKey:@"rsn"];
        
        [delegate chuckOrderWithOptions:dic];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"User and Password could not be empty"] 
                                                        message:[langSetting localizedString:@"Please type again and retry"]
                                                       delegate:nil 
                                              cancelButtonTitle:[langSetting localizedString:@"OK"]
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
}

- (void)cancel{
    [delegate chuckOrderWithOptions:nil];
}

#pragma mark Pickview DataSource
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[self.aryReasons objectAtIndex:row] objectForKey:@"DES"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.aryReasons count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    dSelected = row;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (tfAcct == textField | tfPwd == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 10) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:10];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }
    if (tfCount == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 5) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:5];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }
    return YES;
}
@end
