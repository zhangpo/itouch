//
//  BSCombineTableView.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-21.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "BSCombineTableView.h"
#import "CVLocalizationSetting.h"

@implementation BSCombineTableView
@synthesize delegate,tfNewTable,tfOldTable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        langSetting = [CVLocalizationSetting sharedInstance];
        // Initialization code
        [self setTitle:[langSetting localizedString:@"combine Table"]];
        
        lblOldTable = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 70, 25)];
        lblOldTable.textAlignment = NSTextAlignmentCenter;
        lblOldTable.backgroundColor = [UIColor clearColor];
        lblOldTable.font = [UIFont systemFontOfSize:15.0f];
        lblOldTable.text = [langSetting localizedString:@"major Table"];//@"当前台位:";
        [self addSubview:lblOldTable];
        [lblOldTable release];
        
        lblNewTable = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, 70, 25)];
        lblNewTable.textAlignment = NSTextAlignmentCenter;
        lblNewTable.backgroundColor = [UIColor clearColor];
        lblNewTable.font = [UIFont systemFontOfSize:15.0f];
        lblNewTable.text = [langSetting localizedString:@"minor Table"];//@"目标台位:";
        [self addSubview:lblNewTable];
        [lblNewTable release];
        
        tfOldTable = [[UITextField alloc] initWithFrame:CGRectMake(95, 55, 140, 25)];
        tfNewTable = [[UITextField alloc] initWithFrame:CGRectMake(95, 95, 140, 25)];
        tfOldTable.borderStyle = UITextBorderStyleRoundedRect;
        tfNewTable.borderStyle = UITextBorderStyleRoundedRect;
        
        tfNewTable.keyboardType = UIKeyboardTypeDecimalPad;
        tfOldTable.keyboardType = UIKeyboardTypeDecimalPad;
        
        tfOldTable.delegate = self;
        tfNewTable.delegate = self;
        
        [self addSubview:tfOldTable];
        [self addSubview:tfNewTable];
        
        [tfOldTable release];
        [tfNewTable release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(75, 135, 40, 30);
        [btnConfirm setTitle:[langSetting localizedString:@"OK"] forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(160, 135, 60, 30);
        [btnCancel setTitle:[langSetting localizedString:@"Cancel"] forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc
{
    self.tfOldTable = nil;
    self.tfNewTable = nil;
    self.delegate = nil;
    [super dealloc];
}

- (void)confirm{
    NSString *newTable = [tfNewTable text];
    NSString *oldTable = [tfOldTable text];
    if ([tfOldTable.text length]<=0 | [tfNewTable.text length]<=0 ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Table could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else if ([newTable isEqualToString:oldTable]){//主台位和副台位不能相同
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"Master station and vice same not the same"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if ([tfOldTable.text length]>0)
            [dic setObject:tfOldTable.text forKey:@"oldtable"];
        if ([tfNewTable.text length]>0)
            [dic setObject:tfNewTable.text forKey:@"newtable"];
        
        [delegate combineTableWithOptions:dic];
    }
}

- (void)cancel{
    [delegate combineTableWithOptions:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (tfNewTable == textField | tfOldTable == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 10) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:10];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }
    return YES;
}

@end
