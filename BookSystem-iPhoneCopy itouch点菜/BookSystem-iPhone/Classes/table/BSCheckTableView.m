//
//  BSCheckTableView.m
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BSCheckTableView.h"
#import "CVLocalizationSetting.h"
#import "BSDataProvider.h"

@implementation BSCheckTableView
@synthesize delegate;
@synthesize strArea,strFloor,strStatus;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CVLocalizationSetting *langSetting = [CVLocalizationSetting sharedInstance];
        // Initialization code
        [self setTitle:[langSetting localizedString:@"List Table"]];
        
//        lblAcct = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 80, 30)];
//        lblAcct.textAlignment = UITextAlignmentRight;
//        lblAcct.backgroundColor = [UIColor clearColor];
//        lblAcct.text = [langSetting localizedString:@"User:"];//@"工号:";
//        [self addSubview:lblAcct];
//        [lblAcct release];
//        
//        lblPwd = [[UILabel alloc] initWithFrame:CGRectMake(15, 130, 80, 30)];
//        lblPwd.textAlignment = UITextAlignmentRight;
//        lblPwd.backgroundColor = [UIColor clearColor];
//        lblPwd.text = [langSetting localizedString:@"Password:"];//@"密码:";
//        [self addSubview:lblPwd];
//        [lblPwd release];
        
        lblArea = [[UILabel alloc] initWithFrame:CGRectMake(15, 180-50, 80, 30)];
        lblArea.textAlignment = NSTextAlignmentCenter;
        lblArea.backgroundColor = [UIColor clearColor];
        lblArea.text = [NSString stringWithFormat:@"%@ %@",[langSetting localizedString:@"All"],[langSetting localizedString:@"Area"]];//@"区域:";
        [self addSubview:lblArea];
        [lblArea release];
        
        lblFloor = [[UILabel alloc] initWithFrame:CGRectMake(15, 230-50, 80, 30)];
        lblFloor.textAlignment = NSTextAlignmentCenter;
        lblFloor.backgroundColor = [UIColor clearColor];
        lblFloor.text = [NSString stringWithFormat:@"%@ %@",[langSetting localizedString:@"All"],[langSetting localizedString:@"Floor"]];//@"楼层:";
        [self addSubview:lblFloor];
        [lblFloor release];
        
        lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(15, 230-50, 80, 30)];
        lblStatus.backgroundColor = [UIColor clearColor];
        lblStatus.text = [NSString stringWithFormat:@"%@ %@",[langSetting localizedString:@"All"],[langSetting localizedString:@"Status"]];;//@"楼层:";
        [self addSubview:lblStatus];
        [lblStatus release];
        
        
        
//        tfAcct = [[UITextField alloc] initWithFrame:CGRectMake(100, 80, 350, 30)];
//        tfPwd = [[UITextField alloc] initWithFrame:CGRectMake(100, 130, 350, 30)];
////        tfArea = [[UITextField alloc] initWithFrame:CGRectMake(100, 180, 350, 30)];
////        tfFloor = [[UITextField alloc] initWithFrame:CGRectMake(100, 230, 350, 30)];
//        tfAcct.borderStyle = UITextBorderStyleRoundedRect;
//        tfPwd.borderStyle = UITextBorderStyleRoundedRect;
//        tfPwd.secureTextEntry = YES;
//        [self addSubview:tfAcct];
//        [self addSubview:tfPwd];
//        [tfAcct release];
//        [tfPwd release];
//        tfArea.borderStyle = UITextBorderStyleRoundedRect;
//        tfFloor.borderStyle = UITextBorderStyleRoundedRect;
        
        tvArea = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 200)];
        tvArea.tag = 100;
        tvArea.delegate = self;
        tvArea.dataSource = self;
        UIViewController *vc = [[UIViewController alloc] init];
        [vc.view addSubview:tvArea];
        [tvArea release];
        popArea = [[UIPopoverController alloc] initWithContentViewController:vc];
        [vc release];
        [popArea setPopoverContentSize:tvArea.frame.size];
        
        
        tvFloor = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 200)];
        tvFloor.delegate = self;
        tvFloor.dataSource = self;
        tvFloor.tag = 101;
        vc = [[UIViewController alloc] init];
        [vc.view addSubview:tvFloor];
        [tvFloor release];
        popFloor = [[UIPopoverController alloc] initWithContentViewController:vc];
        [vc release];
        [popFloor setPopoverContentSize:tvFloor.frame.size];
        
        tvStatus = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 200)];
        tvStatus.tag = 102;
        tvStatus.delegate = self;
        tvStatus.dataSource = self;
        vc = [[UIViewController alloc] init];
        [vc.view addSubview:tvStatus];
        [tvStatus release];
        popStatus = [[UIPopoverController alloc] initWithContentViewController:vc];
        [vc release];
        [popStatus setPopoverContentSize:tvStatus.frame.size];
        
        
        btnArea = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnArea.frame = CGRectMake(20, 180-50, 120, 50);
        [btnArea setTitle:[langSetting localizedString:@"Area"] forState:UIControlStateNormal];
        [btnArea addTarget:self action:@selector(areaClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnArea];
        
        btnFloor = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnFloor.frame = CGRectMake(180, 180-50, 120, 50);
        [btnFloor setTitle:[langSetting localizedString:@"Floor"] forState:UIControlStateNormal];
        [btnFloor addTarget:self action:@selector(floorClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnFloor];
        
        btnStatus = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnStatus.frame = CGRectMake(340, 180-50, 120, 50);
        [btnStatus setTitle:[langSetting localizedString:@"Status"] forState:UIControlStateNormal];
        [btnStatus addTarget:self action:@selector(statusClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnStatus];
        
        lblArea.frame = CGRectMake(20, 240-50, 120, 20);
        lblArea.textAlignment = NSTextAlignmentCenter;
        lblFloor.frame = CGRectMake(180, 240-50, 120, 20);
        lblFloor.textAlignment = NSTextAlignmentCenter;
        lblStatus.frame = CGRectMake(340, 240-50, 120, 20);
        lblStatus.textAlignment = NSTextAlignmentCenter;
        
        btnCheck = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCheck.frame = CGRectMake(105, 275, 100, 30);
        [btnCheck setTitle:[langSetting localizedString:@"List Table"] forState:UIControlStateNormal];
        [self addSubview:btnCheck];
        btnCheck.tag = 700;
        [btnCheck addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        
        btnCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCancel.frame = CGRectMake(245, 275, 100, 30);
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
    self.delegate = nil;
    self.strArea = nil;
    self.strFloor = nil;
    self.strStatus = nil;
    [popArea release];
    [popFloor release];
    [popStatus release];
    
    [super dealloc];
}


- (void)confirm{
    BOOL bAuth = NO;
    
    if ([tfAcct.text length]>0 && [tfPwd.text length]>0)
        bAuth = YES;
    
    if (1){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
//        [dic setObject:tfAcct.text forKey:@"user"];
//        [dic setObject:tfPwd.text forKey:@"pwd"];
        if (self.strArea)
            [dic setObject:strArea forKey:@"area"];
        if (self.strFloor)
            [dic setObject:strFloor forKey:@"floor"];
        if (self.strStatus)
            [dic setObject:strStatus forKey:@"status"];
//        [delegate checkTableWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:tfAcct.text,@"user",tfPwd.text,@"pwd",nil]];
        NSLog(@"%@",dic);
        [delegate checkTableWithOptions:dic];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"工号或密码错误" message:@"请重新输入工号或密码再尝试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
}

- (void)cancel{
    [delegate checkTableWithOptions:nil];
}

#pragma mark UITableView Delegate  & Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    NSString *identifier = @"CellIdentifier";
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease]; 
    }
    if (tvArea==tableView){
        cell.textLabel.text = [[[dp getArea] objectAtIndex:indexPath.row] objectForKey:@"DES"];
    }
    else if (tvFloor==tableView){
        cell.textLabel.text = [[[dp getFloor] objectAtIndex:indexPath.row] objectForKey:@"DES"];
    }
    else{
        cell.textLabel.text = [[dp getStatus] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    if (tvArea==tableView){
        return [[dp getArea] count];
    }
    else if (tvFloor==tableView){
        return [[dp getFloor] count];
    }
    else{
        return [[dp getStatus] count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BSDataProvider *dp = [BSDataProvider sharedInstance];
    int index = [indexPath row];
    if (tvArea==tableView){
        self.strArea = [[[dp getArea] objectAtIndex:indexPath.row] objectForKey:@"DES"];
//        NSLog(@"self.strArea = %@",self.strArea);
        lblArea.text = self.strArea;
    }
    else if (tvFloor==tableView){
        self.strFloor = [[[dp getFloor] objectAtIndex:indexPath.row] objectForKey:@"DES"];
        lblFloor.text = self.strFloor;
    }
    else{
        self.strStatus = 0==index?@"A":(1==index?@"B":@"C");
        lblStatus.text = [[dp getStatus] objectAtIndex:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}


#pragma mark Button Clicked
- (void)areaClicked{
    [popArea presentPopoverFromRect:btnArea.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)floorClicked{
    [popFloor presentPopoverFromRect:btnFloor.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)statusClicked{
    [popStatus presentPopoverFromRect:btnStatus.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
@end
