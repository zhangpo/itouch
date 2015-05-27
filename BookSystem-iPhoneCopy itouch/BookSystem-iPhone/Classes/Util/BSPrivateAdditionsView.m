//
//  BSAdditionsView.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-14.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "BSAdditionsView.h"
#import "BSDataProvider.h"
#import "AppDelegate.h"

@interface BSAdditionsView()

@property (nonatomic,retain) NSMutableArray *arySelectedAdditions,*aryResult;

@end

@implementation BSAdditionsView
@synthesize arySelectedAdditions,aryResult,delegate;

- (void)dealloc{
    self.arySelectedAdditions = nil;
    self.aryResult = nil;
    self.delegate = nil;
    
    [super dealloc];
}

+ (BSAdditionsView *)additionsViewWithDelegate:(id<BSAdditionsViewDelegate>)delegate_ additions:(NSArray *)additions{
    BSAdditionsView *v = [[BSAdditionsView alloc] initWithDelegate:delegate_ additions:additions];
    return [v autorelease];
}

- (id)initWithDelegate:(id<BSAdditionsViewDelegate>)delegate_ additions:(NSArray *)additions;
{
    self = [super init];
    if (self) {
        // Initialization code
        self.delegate = delegate_;
        self.aryResult = [NSMutableArray arrayWithArray:[[BSDataProvider sharedInstance] getAdditions]];
        self.arySelectedAdditions = [NSMutableArray arrayWithArray:additions];
        
        float h = [[UIScreen mainScreen] bounds].size.height;
        float padding = 10;
        
        self.frame = CGRectMake(padding, 20+padding, 320-padding*2, h-20-padding*2);
        self.backgroundColor = [UIColor clearColor];
        [self.layer setCornerRadius:10.0];
        [self.layer setMasksToBounds:YES];
        self.clipsToBounds = YES;
        
        UIView *skinView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        skinView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        skinView.backgroundColor = [UIColor blackColor];
        skinView.alpha = 0.8f;
        [self addSubview:skinView];
        [skinView release];
        
        UIButton *btncancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btncancel.frame = CGRectMake(self.frame.size.width - (kPadding+40), 0,50, 35);
        [btncancel setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [btncancel setImage:[UIImage imageNamed:@"close_selected.png"] forState:UIControlStateHighlighted];
        [btncancel addTarget:self action:@selector(dismissAdditions) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btncancel];
        
        //    NSDictionary *food = dicInfo;
        //    int index = 0;
        
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(kPadding, kPadding+20, self.frame.size.width-2*kPadding, self.frame.size.height-2*kPadding-20) style:UITableViewStylePlain];
        tv.delegate = self;
        tv.dataSource = self;
        [self addSubview:tv];
        [tv release];
        tv.tag = 777;
        
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        searchBar.delegate = self;
        tv.tableHeaderView = searchBar;
        [searchBar release];
        
        
    }
    return self;
}

- (void)show{
    self.alpha = 0;
    UIWindow *w = (UIWindow *)[(AppDelegate *)[UIApplication sharedApplication].delegate window];
    [w addSubview:self];
    
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismissAdditions{
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark TableView Delegate & DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [[aryResult objectAtIndex:indexPath.row] objectForKey:@"FNAME"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",[[[aryResult objectAtIndex:indexPath.row] objectForKey:@"FPRICE"] floatValue]];
    
    NSArray *ary = aryResult;
    
    
    BOOL selected = NO;
    for (NSDictionary *dic in arySelectedAdditions){
        if ([[[ary objectAtIndex:indexPath.row] objectForKey:@"FNAME"] isEqualToString:[dic objectForKey:@"FNAME"]]){
            selected = YES;
            break;
        }
    }
    cell.selected = selected;
    
    cell.accessoryType = cell.selected?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [aryResult count];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = nil;
    BOOL needAdd = YES;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = !cell.selected;
    int index = -1;
    for (NSDictionary *dicAdd in arySelectedAdditions){
        if ([[dicAdd objectForKey:@"FNAME"] isEqualToString:[[aryResult objectAtIndex:indexPath.row] objectForKey:@"FNAME"]]){
            needAdd = NO;
            str = [dicAdd objectForKey:@"FNAME"];
            index = indexPath.row;
            break;
        }
    }
    
    if (cell.selected && needAdd)
        [arySelectedAdditions addObject:[aryResult objectAtIndex:indexPath.row]];
    else if (!needAdd){
        int i = 0;
        for (NSDictionary *dicAdd in arySelectedAdditions){
            if ([[dicAdd objectForKey:@"FNAME"] isEqualToString:str]){
                [arySelectedAdditions removeObjectAtIndex:i];
                break;
            }
            i++;
        }
    }
    
    //    else if (!cell.selected && !needAdd){
    //        [arySelectedAdditions removeObjectAtIndex:index];
    //    }
    
    
    [tableView reloadData];
    
    if ([(NSObject *)delegate respondsToSelector:@selector(additionsSelected:)]){
        [delegate additionsSelected:arySelectedAdditions];
    }
}


NSInteger intSort(id num1,id num2,void *context){
    int v1 = [[(NSDictionary *)num1 objectForKey:@"FCODE"] intValue];
    int v2 = [[(NSDictionary *)num2 objectForKey:@"FCODE"] intValue];
    
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


#pragma mark SearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSArray *ary = [[BSDataProvider sharedInstance] getAdditions];
    UITableView *tv = (UITableView *)[self viewWithTag:777];
    
    if ([searchText length]>0){
        searchText = [searchText uppercaseString];
        
        
        int count = [ary count];
        [aryResult removeAllObjects];
        for (int i=0;i<count;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            
            NSString *strITCODE = [[dic objectForKey:@"FCODE"] uppercaseString];
            //            NSString *strINIT = [[dic objectForKey:@"INIT"] uppercaseString];
            NSString *strDES = [dic objectForKey:@"FNAME"];
            if ([strITCODE rangeOfString:searchText].location!=NSNotFound ||
                [strDES rangeOfString:searchText].location!=NSNotFound){
                [aryResult addObject:dic];
            }
        }
        
        self.aryResult = [NSMutableArray arrayWithArray:[aryResult sortedArrayUsingFunction:intSort context:NULL]];
    }
    else{
        //        [searchBar resignFirstResponder];
        self.aryResult = [NSMutableArray arrayWithArray:ary];
        self.aryResult = [NSMutableArray arrayWithArray:[aryResult sortedArrayUsingFunction:intSort context:NULL]];
    }
    
    [tv reloadData];
}
-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //  判断输入的是否为数字 (只能输入数字)输入其他字符是不被允许的
    
    if([text isEqualToString:@""])
    {
        return YES;
    }
    else
    {
        //        ^\d{m,n}$
        
        NSString *validRegEx =@"^[a-zA-Z0-9\u4E00-\u9FA5]";
        NSPredicate *regExPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
        BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:text];
        
        if (myStringMatchesRegEx)
            
            return YES;
        
        else
            
            return NO;
    }

}

@end
