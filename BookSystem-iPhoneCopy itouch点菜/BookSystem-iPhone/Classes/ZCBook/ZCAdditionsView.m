//
//  BSAdditionsView.m
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-14.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "ZCAdditionsView.h"
#import "BSDataProvider.h"
#import "AppDelegate.h"

@interface ZCAdditionsView()

@property (nonatomic,retain) NSMutableArray *arySelectedAdditions,*aryResult;

@end

@implementation ZCAdditionsView
@synthesize arySelectedAdditions,aryResult,delegate;

- (void)dealloc{
    self.arySelectedAdditions = nil;
    self.aryResult = nil;
    self.delegate = nil;
    
    [super dealloc];
}

+ (ZCAdditionsView *)additionsViewWithDelegate:(id<ZCAdditionsViewDelegate>)delegate_ additions:(NSArray *)additions{
    ZCAdditionsView *v = [[ZCAdditionsView alloc] initWithDelegate:delegate_ additions:additions];
    return [v autorelease];
}

- (id)initWithDelegate:(id<ZCAdditionsViewDelegate>)delegate_ additions:(NSArray *)additions;
{
    self = [super init];
    if (self) {
        self.delegate = delegate_;
        aryResult = [[NSMutableArray arrayWithArray:[[BSDataProvider sharedInstance] getAdditions_zc]] retain];
        self.arySelectedAdditions = [NSMutableArray arrayWithArray:additions];
        
        aryCustomAddition = [[NSMutableArray array] retain];
        for (NSDictionary *dic in additions) {
            if ([dic objectForKey:@"custom"]) {
                [aryCustomAddition addObject:dic];
            }
        }
        
        arySearchMatched = [NSMutableArray arrayWithArray:aryCustomAddition];
        [arySearchMatched addObjectsFromArray:self.aryResult];
        [arySearchMatched retain];
        
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
        
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(kPadding, kPadding+20+44, self.frame.size.width-2*kPadding, self.frame.size.height-2*kPadding-20-44) style:UITableViewStylePlain];
        tv.delegate = self;
        tv.dataSource = self;
        [self addSubview:tv];
        [tv release];
        tv.tag = 777;
        
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(kPadding, kPadding+20, tv.size.width, 44)];
        searchBar.delegate = self;
        [self addSubview:searchBar];
        [searchBar release];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        //      [btn setTitle:@"+" forState:UIControlStateNormal];
        btn.frame = CGRectMake(245, 26, 50, 50);
        [self addSubview:btn];
        [btn addTarget:self action:@selector(addCustiomAddition) forControlEvents:UIControlEventTouchUpInside];
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

- (void)addCustiomAddition{
    if ([searchBar.text length]>0){
        for (NSDictionary *dic in aryCustomAddition){
            if ([[dic objectForKey:@"DES"] isEqualToString:searchBar.text])
                return;
        }
        NSDictionary *dicToAdd = [NSDictionary dictionaryWithObjectsAndKeys:searchBar.text,@"DES",@"0.0",@"PRICE1",@"1",@"custom", nil];
        [aryCustomAddition addObject:dicToAdd];
        
        [arySearchMatched removeAllObjects];
        [arySearchMatched addObjectsFromArray:aryCustomAddition];
        [arySearchMatched addObjectsFromArray:aryResult];
         searchBar.text = nil;
        
        UITableView *tv = (UITableView *)[self viewWithTag:777];
        [tv reloadData];
        
        [arySelectedAdditions addObject:dicToAdd];
        NSMutableArray *aryAll = [NSMutableArray arrayWithArray:arySelectedAdditions];

        if ([(NSObject *)delegate respondsToSelector:@selector(additionsSelected:)]){
            [delegate additionsSelected:aryAll];
        }
        [searchBar resignFirstResponder];
    }
}

#pragma mark TableView Delegate & DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [[arySearchMatched objectAtIndex:indexPath.row] objectForKey:@"DES"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",[[[arySearchMatched objectAtIndex:indexPath.row] objectForKey:@"PRICE1"] floatValue]];
    
    NSArray *ary = arySearchMatched;
    
    
    BOOL selected = NO;
    for (NSDictionary *dic in arySelectedAdditions){
        if ([[[ary objectAtIndex:indexPath.row] objectForKey:@"DES"] isEqualToString:[dic objectForKey:@"DES"]]){
            selected = YES;
            break;
        }
    }
    cell.selected = selected;
    
    cell.accessoryType = cell.selected?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arySearchMatched count];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dictSelected = [arySearchMatched objectAtIndex:indexPath.row];
    if ([aryCustomAddition containsObject:dictSelected]) {
        [aryCustomAddition removeObjectAtIndex:indexPath.row];
        [arySearchMatched removeObjectAtIndex:indexPath.row];
        [arySelectedAdditions removeObject:dictSelected];
    }
    
    NSString *str = nil;
    BOOL needAdd = YES;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = !cell.selected;
    int index = -1;
    for (NSDictionary *dicAdd in arySelectedAdditions){
        if ([[dicAdd objectForKey:@"DES"] isEqualToString:[[arySearchMatched objectAtIndex:indexPath.row] objectForKey:@"DES"]]){
            needAdd = NO;
            str = [dicAdd objectForKey:@"DES"];
            index = indexPath.row;
            break;
        }
    }
    
    if (cell.selected && needAdd)
        [arySelectedAdditions addObject:[arySearchMatched objectAtIndex:indexPath.row]];
    else if (!needAdd){
        int i = 0;
        for (NSDictionary *dicAdd in arySelectedAdditions){
            if ([[dicAdd objectForKey:@"DES"] isEqualToString:str]){
                [arySelectedAdditions removeObjectAtIndex:i];
                break;
            }
            i++;
        }
    }
    
    
    [tableView reloadData];
    
    
    if ([(NSObject *)delegate respondsToSelector:@selector(additionsSelected:)]){
        [delegate additionsSelected:arySelectedAdditions];
    }
}


NSInteger intSort11(id num1,id num2,void *context){
    int v1 = [[(NSDictionary *)num1 objectForKey:@"ITCODE"] intValue];
    int v2 = [[(NSDictionary *)num2 objectForKey:@"ITCODE"] intValue];
    
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


#pragma mark SearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSMutableArray *ary = [NSMutableArray arrayWithArray:[[BSDataProvider sharedInstance] getAdditions_zc]];
    [ary addObjectsFromArray:aryCustomAddition];
    UITableView *tv = (UITableView *)[self viewWithTag:777];
    
    if ([searchText length]>0){
        searchText = [searchText uppercaseString];
        int count = [ary count];
        [arySearchMatched removeAllObjects];
        for (int i=0;i<count;i++){
            NSDictionary *dic = [ary objectAtIndex:i];
            
//            NSString *strITCODE = [[dic objectForKey:@"ITCODE"] uppercaseString];
//            NSString *strINIT = [[dic objectForKey:@"INIT"] uppercaseString];
            NSString *strDES = [[dic objectForKey:@"DES"] uppercaseString];
            if ([strDES rangeOfString:searchText].location!=NSNotFound){
                [arySearchMatched addObject:dic];
            }
//            if ([strITCODE rangeOfString:searchText].location!=NSNotFound ||
//                [strINIT rangeOfString:searchText].location!=NSNotFound ||
//                [strDES rangeOfString:searchText].location!=NSNotFound){
//                [arySearchMatched addObject:dic];
//            }
        }
        
        arySearchMatched = [NSMutableArray arrayWithArray:[arySearchMatched sortedArrayUsingFunction:intSort11 context:NULL]];
    }
    else{
        //        [searchBar resignFirstResponder];
        arySearchMatched = [NSMutableArray arrayWithArray:ary];
        arySearchMatched = [NSMutableArray arrayWithArray:[arySearchMatched sortedArrayUsingFunction:intSort11 context:NULL]];
    }
    [arySearchMatched retain];
    [tv reloadData];
}

@end
