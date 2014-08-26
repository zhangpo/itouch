//
//  BSOpenTableView.m
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSOpenTableView.h"
#import "CVLocalizationSetting.h"

@implementation BSOpenTableView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        langSetting = [CVLocalizationSetting sharedInstance];
        self.transform = CGAffineTransformIdentity;
        [self setTitle:[langSetting localizedString:@"Open Table"]];
        
        manLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 70, 25)];
        manLable.textAlignment = NSTextAlignmentCenter;
        manLable.backgroundColor = [UIColor clearColor];
        manLable.font = [UIFont systemFontOfSize:15.0f];
        manLable.text = [langSetting localizedString:@"Man"];
        [self addSubview:manLable];
        [manLable release];
        
        womanLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 95, 70, 25)];
        womanLable.textAlignment = NSTextAlignmentCenter;
        womanLable.backgroundColor = [UIColor clearColor];
        womanLable.font = [UIFont systemFontOfSize:15.0f];
        womanLable.text = [langSetting localizedString:@"Woman"];
        [self addSubview:womanLable];
        [womanLable release];
        
        
        tfman = [[UITextField alloc] initWithFrame:CGRectMake(95, 55, 140, 25)];
        tfwoman = [[UITextField alloc] initWithFrame:CGRectMake(95, 95, 140, 25)];
        tfman.borderStyle = UITextBorderStyleRoundedRect;
        tfwoman.borderStyle = UITextBorderStyleRoundedRect;
        
        tfman.keyboardType = UIKeyboardTypeNumberPad;
        tfwoman.keyboardType = UIKeyboardTypeNumberPad;
        
        tfman.delegate = self;
        tfwoman.delegate = self;
        
        [self addSubview:tfman];
        [self addSubview:tfwoman];
        
        [tfman release];
        [tfwoman release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(75, 135, 60, 30);
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
        
//        tfwoman.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"] objectForKey:@"username"];
    }
    return self;
}


- (void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}


- (void)confirm{
    if ([tfman.text length]<=0 && [tfwoman.text length]<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"people could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        int man = [tfman.text intValue];
        int woman = [tfwoman.text intValue];
        int mAndwo = man + woman;
        if (mAndwo <= 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"number zero"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else if (mAndwo > 99){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"The total number of not greater than 99"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else{
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            if (woman>0)
                [dic setObject:tfwoman.text forKey:@"woman"];
            if (man>0)
                [dic setObject:tfman.text forKey:@"man"];
            
            [delegate openTableWithOptions:dic];
        }
        
    }
}

- (void)cancel{
    [delegate openTableWithOptions:nil];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{  //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (tfman == textField | tfwoman == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 2) { //如果输入框内容大于20则弹出警告
            textField.text = [toBeString substringToIndex:2];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil message:[langSetting localizedString:@"More words"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
            [alert show];
            return NO;
        }
    }
    return YES;
}
@end
