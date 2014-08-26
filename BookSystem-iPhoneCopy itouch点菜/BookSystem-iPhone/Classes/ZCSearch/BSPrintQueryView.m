//
//  BSPrintQueryView.m
//  BookSystem
//
//  Created by Dream on 11-7-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSPrintQueryView.h"
#import "CVLocalizationSetting.h"

@implementation BSPrintQueryView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        
        [self setTitle:[langSetting localizedString:@"PrintQuery"]];
        
        lblUser = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 40, 25)];
        lblUser.textAlignment = UITextAlignmentRight;
        lblUser.backgroundColor = [UIColor clearColor];
        lblUser.text = [langSetting localizedString:@"User:"];
        [self addSubview:lblUser];
        [lblUser release];
        
        lblType = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, 40, 25)];
        lblType.textAlignment = UITextAlignmentRight;
        lblType.backgroundColor = [UIColor clearColor];
        lblType.text = [langSetting localizedString:@"Type:"];
        [self addSubview:lblType];
        [lblType release];
        

        
        tfUser = [[UITextField alloc] initWithFrame:CGRectMake(60, 45, 190, 25)];
        tfUser.borderStyle = UITextBorderStyleRoundedRect;
        segType = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:[langSetting localizedString:@"QUERY"],[langSetting localizedString:@"TAB"],@"ACCOUNT", nil]];//NIL@"查询单",@"结账单",@"自动打印查询单",
        segType.frame = CGRectMake(60, 85, 200, 25);

        [segType addTarget:self action:@selector(chooseType) forControlEvents:UIControlEventTouchUpInside];
        [segType setSelectedSegmentIndex:0];

        

        
        [self addSubview:tfUser];
        [self addSubview:segType];
        [tfUser release];
        [segType release];

        
        btnPrint = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnPrint.frame = CGRectMake(75, 135, 40, 30);
        [btnPrint setTitle:[langSetting localizedString:@"print"] forState:UIControlStateNormal];
        [self addSubview:btnPrint];
        btnPrint.tag = 700;
        [btnPrint addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(160, 135, 60, 30);
        [btnCancel setTitle:[langSetting localizedString:@"Cancel"] forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

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

- (void)confirm{
    BOOL bAuth = NO;
    
    if ([tfUser.text length]>0)
        bAuth = YES;
    
    if (bAuth){
        NSDictionary *dict;
        int index = [segType selectedSegmentIndex];
        NSString *strType;
        if (0==index)
            strType = @"QUERY";
        else if (1==index)
            strType = @"TAB";
        else
            strType = @"ACCOUNT";
        dict = [NSDictionary dictionaryWithObjectsAndKeys:tfUser.text,@"user",strType,@"type", nil];
        
        [delegate printQueryWithOptions:dict];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"工号错误" message:@"请重新输入工号再尝试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
}

- (void)cancel{
    [delegate printQueryWithOptions:nil];
}

@end
