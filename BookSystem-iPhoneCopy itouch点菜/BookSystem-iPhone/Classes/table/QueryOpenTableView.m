//
//  QueryOpenTableView.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-26.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "QueryOpenTableView.h"
#import "CVLocalizationSetting.h"

@implementation QueryOpenTableView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        langSetting = [CVLocalizationSetting sharedInstance];
        self.transform = CGAffineTransformIdentity;
        [self setTitle:[langSetting localizedString:@"Open Table"]];
        
        manLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 70, 25)];
        manLable.textAlignment = NSTextAlignmentCenter;
        manLable.backgroundColor = [UIColor clearColor];
        manLable.font = [UIFont systemFontOfSize:15.0f];
        manLable.text = [langSetting localizedString:@"Man"];
        [self addSubview:manLable];
        [manLable release];
        
        womanLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, 70, 25)];
        womanLable.textAlignment = NSTextAlignmentCenter;
        womanLable.backgroundColor = [UIColor clearColor];
        womanLable.font = [UIFont systemFontOfSize:15.0f];
        womanLable.text = [langSetting localizedString:@"Woman"];
        [self addSubview:womanLable];
        [womanLable release];
        
        tableLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 70, 25)];
        tableLable.textAlignment = NSTextAlignmentCenter;
        tableLable.backgroundColor = [UIColor clearColor];
        tableLable.font = [UIFont systemFontOfSize:15.0f];
        tableLable.text = [langSetting localizedString:@"Table"];//台位
        [self addSubview:tableLable];
        [tableLable release];
        
        
        tfman = [[UITextField alloc] initWithFrame:CGRectMake(95, 50, 140, 25)];
        tfwoman = [[UITextField alloc] initWithFrame:CGRectMake(95, 85, 140, 25)];
        tfTable = [[UITextField alloc] initWithFrame:CGRectMake(95, 120, 140, 25)];
        tfman.borderStyle = UITextBorderStyleRoundedRect;
        tfwoman.borderStyle = UITextBorderStyleRoundedRect;
        tfTable.borderStyle = UITextBorderStyleRoundedRect;
        
        
        
        [self addSubview:tfman];
        [self addSubview:tfwoman];
        [self addSubview:tfTable];
        
        [tfman release];
        [tfwoman release];
        [tfTable release];
        
        btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnConfirm.frame = CGRectMake(75, 155, 40, 30);
        [btnConfirm setTitle:[langSetting localizedString:@"OK"] forState:UIControlStateNormal];
        [self addSubview:btnConfirm];
        btnConfirm.tag = 700;
        [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(160, 155, 40, 30);
        [btnCancel setTitle:[langSetting localizedString:@"NO"] forState:UIControlStateNormal];
        [self addSubview:btnCancel];
        btnCancel.tag = 701;
        [btnCancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}


- (void)dealloc
{
    self.delegate = nil;
    [super dealloc];
}


- (void)confirm{
    if ([tfman.text length]<=0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[langSetting localizedString:@"Error"] message:[langSetting localizedString:@"User could not be empty"] delegate:nil cancelButtonTitle:[langSetting localizedString:@"OK"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        if ([tfwoman.text length]>0)
            [dic setObject:tfwoman.text forKey:@"woman"];
        if ([tfman.text length]>0)
            [dic setObject:tfman.text forKey:@"man"];
        
        [delegate queryOpenTableWithOptions:dic];
    }
}

- (void)cancel{
    [delegate queryOpenTableWithOptions:nil];
}
@end
